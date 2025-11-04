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

    public func configure(_ config: SDKConfiguration, tokenStore: TokenStore = InMemoryTokenStore()) {
        if state == .configured {
            Logger.warn("SDK already configured; skipping reconfiguration.")
            return
        }

        SDKConfiguration.configure(config)
        self.config = config
        self.api = APIClient.shared
        self.auth = AuthManager(api: api, tokenStore: tokenStore)
        self.license = LicenseManager(api: api, licenseKey: config.licenseKey ?? "")

        Task {
            await AppAttestManager.shared.ensureAttestationIfNeeded()

            do {
                let (cid, _, expiresAt) = try await AttestAPI.shared.fetchChallenge()
                Logger.info("Challenge fetched ✅ id=\(cid.prefix(8))… expires=\(expiresAt)")
            } catch {
                Logger.error("Challenge fetch failed: \(error.localizedDescription)")
            }
        }

        state = .configured
        Logger.info("SDK configured: \(config.environment.rawValue)")
    }
}
