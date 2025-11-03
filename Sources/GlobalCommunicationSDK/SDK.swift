import Foundation

public enum SDKState {
    case unconfigured
    case configured
}

public final class GlobalCommunicationSDK {
    public static let shared = GlobalCommunicationSDK()
    private(set) public var state: SDKState = .unconfigured

    public private(set) var config: SDKConfiguration!
    public private(set) var api: APIClient!
    public private(set) var auth: AuthManager!
    private init() {}

    public func configure(_ config: SDKConfiguration, tokenStore: TokenStore = InMemoryTokenStore()) {

        SDKConfiguration.configure(config)
        self.config = config
        self.api = APIClient.shared
        self.auth = AuthManager(api: api, tokenStore: tokenStore)

        Task {
            await AppAttestManager.shared.ensureAttestationIfNeeded()
        }

        state = .configured
        Logger.info("SDK configured: \(config.environment.rawValue)")
    }
}
