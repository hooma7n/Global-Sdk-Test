import Foundation

public final class AuthManager {
    private let api: APIClient
    private var tokenStore: TokenStore

    public init(api: APIClient, tokenStore: TokenStore) {
        self.api = api
        self.tokenStore = tokenStore
    }

    public struct LoginResponse: Decodable {
        public let accessToken: String
        public let refreshToken: String?
    }

    public func login(email: String, password: String) async throws -> LoginResponse {
        let res: APIClient.LoginResponse = try await api.login(email: email, password: password)
        tokenStore.accessToken = res.accessToken
        tokenStore.refreshToken = res.refreshToken
        return .init(accessToken: res.accessToken, refreshToken: res.refreshToken)
    }

    public func refresh() async throws {
        guard let rt = tokenStore.refreshToken else { return }
        let newAccessToken = try await api.refresh(using: rt)
        tokenStore.accessToken = newAccessToken
    }
}
