import Foundation

struct RequestBuilder {
    static func makeRequest(baseURL: URL,
                            endpoint: Endpoint,
                            defaultHeaders: [String: String],
                            token: String?) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        components.path = components.path.appending(endpoint.path)
        components.queryItems = endpoint.query

        guard let url = components.url else { throw APIError.invalidURL }

        var req = URLRequest(url: url, timeoutInterval: 30)
        req.httpMethod = endpoint.method
        req.httpBody = endpoint.body

        defaultHeaders.forEach { req.addValue($1, forHTTPHeaderField: $0) }
        if let token {
            req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        endpoint.headers?.forEach { req.addValue($1, forHTTPHeaderField: $0) }
        return req
    }
}
