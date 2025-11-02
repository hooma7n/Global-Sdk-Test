import Foundation

public enum SDKState { case unconfigured, configured }

public final class GlobalCommunicationSDK {
    public static let shared = GlobalCommunicationSDK()
    private(set) public var state: SDKState = .unconfigured

    public private(set) var config: SDKConfiguration!
    public private(set) var api: APIClient!
    public private(set) var auth: AuthManager!
    public private(set) var license: LicenseManager!

    private init() {}

    public func configure(_ config: SDKConfiguration) {
        self.config = config

        self.api = APIClient(
            baseURL: config.environment.baseURL,
            defaultHeaders: [
                "X-App-ID": config.appId,
                "Accept": "application/json",
                "Content-Type": "application/json"
            ],
            tokenProvider: { config.tokenStore.accessToken }
        )

        self.license = LicenseManager(api: api, licenseKey: config.licenseKey)
        self.auth = AuthManager(api: api, tokenStore: config.tokenStore)

        if config.useAppAttest {
            AppAttestManager.shared.ensureAttestationIfNeeded()
        }

        state = .configured
        Logger.info("SDK configured: \(config.environment)")
    }
}
