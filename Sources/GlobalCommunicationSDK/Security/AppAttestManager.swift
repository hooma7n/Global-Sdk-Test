import Foundation
import DeviceCheck
import CryptoKit

public final class AppAttestManager {
    public static let shared = AppAttestManager()
    private init() {}

    private let service = DCAppAttestService.shared
    private let keyKey = "com.devotel.glocom.appattest.keyid"

    public func ensureAttestationIfNeeded() async {
        guard service.isSupported else {
            Logger.warn("App Attest not supported (Simulator/old iOS).")
            return
        }
        do {
            if try KeychainHelper.load(key: keyKey) == nil {
                try await register()
            } else {
                Logger.debug("App Attest key already exists.")
            }
        } catch {
            Logger.error("ensureAttestationIfNeeded error: \(error.localizedDescription)")
        }
    }

    private func register() async throws {
        Logger.info("App Attest: registering…")

        let keyId = try await service.generateKey()
        try KeychainHelper.save(value: keyId, for: keyKey)

        let (cid, challenge, expiresAt) = try await AttestAPI.shared.fetchChallenge()
        guard Date().timeIntervalSince1970 < Double(expiresAt)/1000.0 else {
            throw AttestError.challengeExpired
        }

        // Register: SHA256(challenge)
        let clientHash = Data(SHA256.hash(data: challenge))
        let attObj = try await service.attestKey(keyId, clientDataHash: clientHash)

        try await AttestAPI.shared.registerAttestation(
            challengeId: cid,
            clientDataHashHex: clientHash.toHex(),
            keyId: keyId,
            attestationObjectB64Url: attObj.base64UrlString()
        )

        Logger.info("App Attest: registration OK.")
    }

    @discardableResult
    public func assertBeforeSecureCall(purpose: String) async -> Bool {
        do {
            guard let keyId = try KeychainHelper.load(key: keyKey) else {
                Logger.warn("No AppAttest key found — registering new one.")
                try await register()
                return false
            }

            let (cid, challenge, expiresAt) = try await AttestAPI.shared.fetchChallenge()
            guard Date().timeIntervalSince1970 < Double(expiresAt) / 1000.0 else {
                throw AttestError.challengeExpired
            }

            var payload = Data()
            payload.append(challenge)
            payload.append(Data(purpose.utf8))
            let hash = Data(SHA256.hash(data: payload))

            let assertion = try await service.generateAssertion(keyId, clientDataHash: hash)

            try await AttestAPI.shared.verifyAssertion(
                challengeId: cid,
                clientDataHashHex: hash.toHex(),
                keyId: keyId,
                assertionB64Url: assertion.base64UrlString(),
                purpose: purpose
            )

            Logger.debug("App Attest assertion OK for \(purpose).")
            return true

        } catch {
            let message = error.localizedDescription.lowercased()
            if message.contains("key") && message.contains("not found") {
                Logger.warn("App Attest key missing or invalid — re-registering…")
                try? KeychainHelper.delete(key: keyKey)
                try? await register()
                return false
            }

            Logger.error("App Attest assertion failed: \(error.localizedDescription)")
            return false
        }
    }
    
}
