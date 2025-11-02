import Foundation

public protocol TokenStore {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
}

public struct InMemoryTokenStore: TokenStore {
    public var accessToken: String?
    public var refreshToken: String?
    public init() {}
}

public struct SDKConfiguration {
    public let appId: String
    public let environment: Environment
    public let licenseKey: String
    public let useAppAttest: Bool
    public let tokenStore: TokenStore

    public init(appId: String,
                environment: Environment,
                licenseKey: String,
                useAppAttest: Bool = false,
                tokenStore: TokenStore = InMemoryTokenStore()) {
        self.appId = appId
        self.environment = environment
        self.licenseKey = licenseKey
        self.useAppAttest = useAppAttest
        self.tokenStore = tokenStore
    }
}
