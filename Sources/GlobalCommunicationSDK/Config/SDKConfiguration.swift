import Foundation

public enum SDKEnvironment: String, Codable {
    case development
    case staging
    case production

    public var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://global-api-development.devotel.io")!
        case .staging:
            return URL(string: "https://global-api-staging.devotel.io")!
        case .production:
            return URL(string: "https://global-api.devotel.io")!
        }
    }
}

public struct SDKConfiguration: Codable {
    public let environment: SDKEnvironment
    public let tenantId: String
    public let publicSdkKey: String
    public let bundleId: String
    public let licenseKey: String?
    public let customBaseURL: URL?

    public var baseURL: URL { customBaseURL ?? environment.baseURL }

    public init(
        environment: SDKEnvironment,
        tenantId: String,
        publicSdkKey: String,
        bundleId: String? = nil,
        licenseKey: String? = nil,
        customBaseURL: URL? = nil
    ) {
        self.environment = environment
        self.tenantId = tenantId
        self.publicSdkKey = publicSdkKey
        self.bundleId = bundleId ?? SDKConfiguration.resolveHostBundleID()
        self.licenseKey = licenseKey
        self.customBaseURL = customBaseURL
    }

    // MARK: - Resolve bundle id robustly
    private static func resolveHostBundleID() -> String {
        if let id = Bundle.main.bundleIdentifier {
            return id
        }
        if let id = Bundle(for: SDKConfigurationDummy.self).bundleIdentifier {
            return id
        }
        return "unknown.bundle.id"
    }
    private class SDKConfigurationDummy {}

    // MARK: - Shared config
    public static private(set) var current: SDKConfiguration?

    public static func configure(_ config: SDKConfiguration) {
        self.current = config
    }

    public static func reset() { self.current = nil }
}
