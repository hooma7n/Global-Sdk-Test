import Foundation

// MARK: - Errors / DTO
enum AttestError: Error {
    case invalidHTTPStatus(Int)
    case decoding
    case challengeExpired
}

struct DeviceChallengeResponse: Decodable {
    let challengeId: String
    let challenge: String   // hex
    let expiresAt: Int64    // epoch millis
}

// MARK: - AttestAPI
final class AttestAPI {
    static let shared = AttestAPI()
    private init() {}

    private var config: SDKConfiguration {
        guard let cfg = SDKConfiguration.current else {
            fatalError("SDK not configured before calling AttestAPI.")
        }
        return cfg
    }

    // 1) POST /api/v1/sdk/v1/device/challenge
    func fetchChallenge() async throws -> (id: String, data: Data, expiresAt: Int64) {
        let url = config.baseURL.appendingPathComponent("/api/v1/sdk/v1/device/challenge")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "publicSdkKey": config.publicSdkKey,
            "tenantId": config.tenantId,
            "platform": "ios",
            "bundleId": config.bundleId
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw AttestError.decoding }
        guard (200..<300).contains(http.statusCode) else {
            throw AttestError.invalidHTTPStatus(http.statusCode)
        }

        let dto = try JSONDecoder().decode(DeviceChallengeResponse.self, from: data)
        guard let challengeData = Data(hex: dto.challenge) else { throw AttestError.decoding }
        return (dto.challengeId, challengeData, dto.expiresAt)
    }

    // 2) POST /api/v1/sdk/v1/device/register  (attestation register)
    func registerAttestation(
        challengeId: String,
        clientDataHashHex: String,
        keyId: String,
        attestationObjectB64Url: String
    ) async throws {
        let url = config.baseURL.appendingPathComponent("/api/v1/sdk/v1/device/register")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "publicSdkKey": config.publicSdkKey,
            "tenantId": config.tenantId,
            "platform": "ios",
            "bundleId": config.bundleId,
            "challengeId": challengeId,
            "clientDataHash": clientDataHashHex,
            "keyId": keyId,
            "attestationObject": attestationObjectB64Url
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw AttestError.decoding }
        guard (200..<300).contains(http.statusCode) else {
            throw AttestError.invalidHTTPStatus(http.statusCode)
        }
    }

    // 3) POST /api/v1/sdk/v1/device/register  (assertion verify)
    func verifyAssertion(
        challengeId: String,
        clientDataHashHex: String,
        keyId: String,
        assertionB64Url: String,
        purpose: String
    ) async throws {
        let url = config.baseURL.appendingPathComponent("/api/v1/sdk/v1/device/register")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "publicSdkKey": config.publicSdkKey,
            "tenantId": config.tenantId,
            "platform": "ios",
            "bundleId": config.bundleId,
            "flow": "assertion",
            "challengeId": challengeId,
            "clientDataHash": clientDataHashHex,
            "keyId": keyId,
            "assertion": assertionB64Url,
            "purpose": purpose
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw AttestError.decoding }
        guard (200..<300).contains(http.statusCode) else {
            throw AttestError.invalidHTTPStatus(http.statusCode)
        }
    }
}
