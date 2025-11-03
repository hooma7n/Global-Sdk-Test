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
        self.bundleId = bundleId ?? (Bundle.main.bundleIdentifier ?? "unknown.bundle.id")
        self.licenseKey = licenseKey
        self.customBaseURL = customBaseURL
    }

    // MARK: - Shared config
    public static private(set) var current: SDKConfiguration?

    public static func configure(_ config: SDKConfiguration) {
        self.current = config
        Logger.info("SDK configured: \(config.environment.rawValue)")
        Task { await AppAttestManager.shared.ensureAttestationIfNeeded() }
    }

    public static func reset() { self.current = nil }
}
