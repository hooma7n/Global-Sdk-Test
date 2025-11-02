import Foundation
import DeviceCheck

public final class AppAttestManager {
    public static let shared = AppAttestManager()
    private init() {}

    public func ensureAttestationIfNeeded() {
        guard DCAppAttestService.shared.isSupported else {
            Logger.warn("App Attest not supported on this device.")
            return
        }
        Logger.info("App Attest supported. (stub)")
    }
}
