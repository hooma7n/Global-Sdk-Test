import Foundation

public protocol Endpoint {
    var path: String { get }
    var method: String { get }
    var query: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

public enum API: Endpoint {
    case login(email: String, password: String)
    case refresh(token: String)
    case licenseVerify(key: String)
    case getProfile
    case custom(path: String, method: String, query: [URLQueryItem]?, body: Data?)

    public var path: String {
        switch self {
        case .login:              return "/auth/login"     // TODO
        case .refresh:            return "/auth/refresh"   // TODO
        case .licenseVerify:      return "/license/verify" // TODO
        case .getProfile:         return "/user/profile"   // TODO
        case .custom(let p, _, _, _): return p
        }
    }

    public var method: String {
        switch self {
        case .login, .refresh, .licenseVerify: return "POST"
        case .getProfile: return "GET"
        case .custom(_, let m, _, _): return m
        }
    }

    public var query: [URLQueryItem]? {
        switch self {
        case .getProfile: return nil
        case .login, .refresh, .licenseVerify: return nil
        case .custom(_, _, let q, _): return q
        }
    }

    public var headers: [String: String]? { nil }

    public var body: Data? {
        switch self {
        case .login(let email, let password):
            return try? JSONSerialization.data(withJSONObject: ["email": email, "password": password])
        case .refresh(let token):
            return try? JSONSerialization.data(withJSONObject: ["refreshToken": token])
        case .licenseVerify(let key):
            return try? JSONSerialization.data(withJSONObject: ["licenseKey": key])
        case .getProfile: return nil
        case .custom(_, _, _, let b): return b
        }
    }
}
