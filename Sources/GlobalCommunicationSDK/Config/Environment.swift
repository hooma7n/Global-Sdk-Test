import Foundation

public enum Environment: String {
    case development
    case staging
    case production

    public var baseURL: URL {
        switch self {
        case .development: return URL(string: "https://global-api-development.devotel.io")!
        case .staging:     return URL(string: "https://global-api-development.devotel.io")!
        case .production:  return URL(string: "https://global-api-development.devotel.io")!
        }
    }
}
