import Foundation

public struct ApiResponse<T: Decodable>: Decodable {
    public let success: Bool?
    public let code: String?
    public let message: String?
    public let data: T?
}
