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
        let res: LoginResponse = try await api.request(API.login(email: email, password: password))
        tokenStore.accessToken = res.accessToken
        tokenStore.refreshToken = res.refreshToken
        return res
    }

    public func refresh() async throws {
        guard let rt = tokenStore.refreshToken else { return }
        struct RefreshRes: Decodable { let accessToken: String }
        let res: RefreshRes = try await api.request(API.refresh(token: rt))
        tokenStore.accessToken = res.accessToken
    }
}
