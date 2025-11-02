import Foundation

public enum APIError: Error, CustomStringConvertible {
    case decoding(Error)
    case server(status: Int, code: String?, message: String?)
    case network(Error)
    case timeout
    case unauthorized
    case invalidURL
    case unknown

    public var description: String {
        switch self {
        case .decoding(let e):     return "Decoding error: \(e)"
        case .server(let s, let c, let m): return "Server error (\(s)) [\(c ?? "-")]: \(m ?? "-")"
        case .network(let e):      return "Network error: \(e.localizedDescription)"
        case .timeout:             return "Request timed out"
        case .unauthorized:        return "Unauthorized"
        case .invalidURL:          return "Invalid URL"
        case .unknown:             return "Unknown error"
        }
    }
}
