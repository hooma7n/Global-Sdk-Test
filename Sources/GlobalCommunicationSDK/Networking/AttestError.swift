import Foundation

enum AttestError: Error {
    case invalidHTTPStatus(Int)
    case decoding
    case challengeExpired
    case notSupported
}

struct DeviceChallengeDTO: Decodable {
    let challengeId: String
    let challenge: String
    let expiresAt: Int64
}

final class AttestAPI {
    static let shared = AttestAPI()
    private init() {}

    // Common helpers
    private var config: SDKConfiguration {
        guard let cfg = SDKConfiguration.current else {
            fatalError("SDK not configured. Call SDKConfiguration.configure(_:) before using AttestAPI.")
        }
        return cfg
    }

    private var baseURL: URL { config.baseURL }
    private var publicSdkKey: String { config.publicSdkKey }
    private var tenantId: String { config.tenantId }
    private var bundleId: String { config.bundleId }

    // 1) POST /api/v1/sdk/v1/device/challenge
    func fetchChallenge() async throws -> (id: String, data: Data, expiresAt: Int64) {
        let url = baseURL.appendingPathComponent("/api/v1/sdk/v1/device/challenge")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "publicSdkKey": publicSdkKey,
            "tenantId": tenantId,
            "platform": "ios",
            "bundleId": bundleId
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw AttestError.decoding }
        guard (200..<300).contains(http.statusCode) else { throw AttestError.invalidHTTPStatus(http.statusCode) }

        let dto = try JSONDecoder().decode(DeviceChallengeDTO.self, from: data)
        guard let challengeData = Data(hex: dto.challenge) else { throw AttestError.decoding }
        return (dto.challengeId, challengeData, dto.expiresAt)
    }

    func registerAttestation(
        challengeId: String,
        clientDataHashHex: String,
        keyId: String,
        attestationObjectB64Url: String
    ) async throws {
        let url = baseURL.appendingPathComponent("/api/v1/sdk/v1/device/register")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "publicSdkKey": publicSdkKey,
            "tenantId": tenantId,
            "platform": "ios",
            "bundleId": bundleId,
            "challengeId": challengeId,
            "clientDataHash": clientDataHashHex,
            "keyId": keyId,
            "attestationObject": attestationObjectB64Url
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw AttestError.decoding }
        guard (200..<300).contains(http.statusCode) else { throw AttestError.invalidHTTPStatus(http.statusCode) }
    }

    // 3) POST /api/v1/sdk/v1/device/register  (assertion verify with flow)
    func verifyAssertion(
        challengeId: String,
        clientDataHashHex: String,
        keyId: String,
        assertionB64Url: String,
        purpose: String
    ) async throws {
        let url = baseURL.appendingPathComponent("/api/v1/sdk/v1/device/register")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "publicSdkKey": publicSdkKey,
            "tenantId": tenantId,
            "platform": "ios",
            "bundleId": bundleId,
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
        guard (200..<300).contains(http.statusCode) else { throw AttestError.invalidHTTPStatus(http.statusCode) }
    }
}
