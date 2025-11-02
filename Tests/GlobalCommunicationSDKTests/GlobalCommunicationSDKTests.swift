import XCTest
@testable import GlobalCommunicationSDK

final class GlobalCommunicationSDKTests: XCTestCase {
    func testConfigure() {
        let cfg = SDKConfiguration(appId: "devotel-app",
                                   environment: .development,
                                   licenseKey: "LICENSE-KEY-XXX")
        GlobalCommunicationSDK.shared.configure(cfg)
        XCTAssertEqual(GlobalCommunicationSDK.shared.state, .configured)
    }
}
