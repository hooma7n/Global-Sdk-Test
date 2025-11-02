import Foundation

public final class LicenseManager {
    private let api: APIClient
    private let licenseKey: String

    public init(api: APIClient, licenseKey: String) {
        self.api = api
        self.licenseKey = licenseKey
    }

    public struct LicenseVerifyResponse: Decodable {
        public let valid: Bool
        public let plan: String?
        public let expiresAt: String?
    }

    public func verify() async throws -> LicenseVerifyResponse {
        try await api.request(API.licenseVerify(key: licenseKey))
    }
}
