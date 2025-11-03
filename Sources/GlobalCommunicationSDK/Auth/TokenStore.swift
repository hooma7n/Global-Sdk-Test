import Foundation

public protocol TokenStore {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
}

public final class InMemoryTokenStore: TokenStore {
    public init() {}
    public var accessToken: String?
    public var refreshToken: String?
}
