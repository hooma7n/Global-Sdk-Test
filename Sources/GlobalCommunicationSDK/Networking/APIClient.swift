import Foundation

// MARK: - Local Errors for this client
enum APIClientError: Error {
    case notConfigured
    case invalidHTTPStatus(Int)
    case decoding
}

// MARK: - DTOs
struct DeviceChallengeResponse: Decodable {
    let challengeId: String
    let challenge: String
    let expiresAt: Int64
}

// MARK: - APIClient
public final class APIClient {
    public static let shared = APIClient()
    private init() {}

    // Safely unwrap global config once
    private var config: SDKConfiguration {
        guard let cfg = SDKConfiguration.current else {
            fatalError("SDK not configured. Call SDKConfiguration.configure(_:) before using APIClient.")
        }
        return cfg
    }

    private var baseURL: URL { config.baseURL }

    // POST /api/v1/sdk/v1/device/challenge
    public func fetchDeviceChallenge() async throws -> (id: String, data: Data, expiresAt: Int64) {
        let url = baseURL.appendingPathComponent("/api/v1/sdk/v1/device/challenge")
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
        guard let http = resp as? HTTPURLResponse else { throw APIClientError.decoding }
        guard (200..<300).contains(http.statusCode) else {
            throw APIClientError.invalidHTTPStatus(http.statusCode)
        }

        let dto = try JSONDecoder().decode(DeviceChallengeResponse.self, from: data)
        guard let challengeData = Data(hex: dto.challenge) else { throw APIClientError.decoding }
        return (dto.challengeId, challengeData, dto.expiresAt)
    }

    // POST /api/v1/sdk/v1/device/register (attestation register)
    public func registerDeviceAppAttest(
        challengeId: String,
        clientDataHashHex: String,
        keyId: String,
        attestationObject: Data
    ) async throws {
        let url = baseURL.appendingPathComponent("/api/v1/sdk/v1/device/register")
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
            "attestationObject": attestationObject.base64UrlString()
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIClientError.decoding }
        guard (200..<300).contains(http.statusCode) else {
            throw APIClientError.invalidHTTPStatus(http.statusCode)
        }
    }

    // POST /api/v1/sdk/v1/device/register (assertion verify with flow)
    public func verifyDeviceAssertion(
        challengeId: String,
        clientDataHashHex: String,
        keyId: String,
        assertion: Data,
        purpose: String
    ) async throws {
        let url = baseURL.appendingPathComponent("/api/v1/sdk/v1/device/register")
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
            "assertion": assertion.base64UrlString(),
            "purpose": purpose
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIClientError.decoding }
        guard (200..<300).contains(http.statusCode) else {
            throw APIClientError.invalidHTTPStatus(http.statusCode)
        }
    }
}

import Foundation

extension APIClient {
    @discardableResult
    private func postJSON<T: Decodable>(
        path: String,
        body: [String: Any]
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let cfg = self.config
        req.setValue(cfg.publicSdkKey, forHTTPHeaderField: "X-SDK-Key")
        req.setValue(cfg.tenantId,     forHTTPHeaderField: "X-Tenant-ID")
        req.setValue("ios",            forHTTPHeaderField: "X-Platform")
        req.setValue(cfg.bundleId,     forHTTPHeaderField: "X-Bundle-ID")

        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIClientError.invalidHTTPStatus((resp as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

private let LOGIN_PATH  = "/api/v1/sdk/v1/auth/login"
private let REFRESH_PATH = "/api/v1/sdk/v1/auth/refresh"

extension APIClient {
    public struct LoginResponse: Decodable {
        public let accessToken: String
        public let refreshToken: String?
    }

    public func login(email: String, password: String) async throws -> LoginResponse {
        return try await postJSON(
            path: LOGIN_PATH,
            body: [
                "email": email,
                "password": password,
                "tenantId": config.tenantId,
                "platform": "ios",
                "bundleId": config.bundleId,
                "publicSdkKey": config.publicSdkKey
            ]
        )
    }

    public func refresh(using refreshToken: String) async throws -> String {
        struct RefreshRes: Decodable { let accessToken: String }
        let res: RefreshRes = try await postJSON(
            path: REFRESH_PATH,
            body: [
                "refreshToken": refreshToken,
                "tenantId": config.tenantId,
                "platform": "ios",
                "bundleId": config.bundleId,
                "publicSdkKey": config.publicSdkKey
            ]
        )
        return res.accessToken
    }
}
