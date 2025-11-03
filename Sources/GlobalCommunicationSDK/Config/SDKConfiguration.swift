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
    public let customBaseURL: URL?

    public var baseURL: URL { customBaseURL ?? environment.baseURL }

    /// Default headers many endpoints will want
    public var defaultHeaders: [String: String] {
        [
            "X-SDK-Key": publicSdkKey,
            "X-Tenant-ID": tenantId,
            "X-Platform": "ios",
            "X-Bundle-ID": bundleId,
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    public init(
        environment: SDKEnvironment,
        tenantId: String,
        publicSdkKey: String,
        bundleId: String,
        customBaseURL: URL? = nil
    ) {
        self.environment = environment
        self.tenantId = tenantId
        self.publicSdkKey = publicSdkKey
        self.bundleId = bundleId.isEmpty ? (Bundle.main.bundleIdentifier ?? bundleId) : bundleId
        self.customBaseURL = customBaseURL
    }

    // MARK: - Global shared config
    public static private(set) var current: SDKConfiguration?

    public static var isConfigured: Bool { current != nil }

    @discardableResult
    public static func requireCurrent(file: StaticString = #fileID, line: UInt = #line) -> SDKConfiguration {
        guard let cfg = current else {
            fatalError("SDKConfiguration not configured. Call SDKConfiguration.configure(_:) first. (\(file):\(line))")
        }
        return cfg
    }

    /// Configures SDK globally
    public static func configure(_ config: SDKConfiguration) {
        self.current = config
        Logger.info("SDK configured: \(config.environment.rawValue)")
        Task { await AppAttestManager.shared.ensureAttestationIfNeeded() }
    }

    /// Useful for tests
    public static func reset() { self.current = nil }
}
