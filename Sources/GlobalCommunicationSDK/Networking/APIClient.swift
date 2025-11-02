import Foundation

public final class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let defaultHeaders: [String: String]
    private let tokenProvider: () -> String?

    public init(baseURL: URL,
                session: URLSession = .shared,
                defaultHeaders: [String: String] = [:],
                tokenProvider: @escaping () -> String? = { nil }) {
        self.baseURL = baseURL
        self.session = session
        self.defaultHeaders = defaultHeaders
        self.tokenProvider = tokenProvider
    }

    public func request<T: Decodable>(_ endpoint: Endpoint, as: T.Type = T.self) async throws -> T {
        let req = try RequestBuilder.makeRequest(baseURL: baseURL,
                                                 endpoint: endpoint,
                                                 defaultHeaders: defaultHeaders,
                                                 token: tokenProvider())
        Logger.debug("→ \(req.httpMethod ?? "-") \(req.url?.absoluteString ?? "-")")
        do {
            let (data, resp) = try await session.data(for: req)
            return try Self.handle(data: data, response: resp)
        } catch {
            throw (error as? APIError) ?? APIError.network(error)
        }
    }

    public func request<T: Decodable>(_ endpoint: Endpoint, completion: @escaping (Result<T, APIError>) -> Void) {
        do {
            let req = try RequestBuilder.makeRequest(baseURL: baseURL,
                                                     endpoint: endpoint,
                                                     defaultHeaders: defaultHeaders,
                                                     token: tokenProvider())
            Logger.debug("→ \(req.httpMethod ?? "-") \(req.url?.absoluteString ?? "-")")
            session.dataTask(with: req) { data, response, err in
                if let err = err { return completion(.failure(.network(err))) }
                guard let data = data, let response = response else { return completion(.failure(.unknown)) }
                do {
                    let result: T = try Self.handle(data: data, response: response)
                    completion(.success(result))
                } catch let apiErr as APIError {
                    completion(.failure(apiErr))
                } catch {
                    completion(.failure(.decoding(error)))
                }
            }.resume()
        } catch let e as APIError {
            completion(.failure(e))
        } catch {
            completion(.failure(.unknown))
        }
    }

    private static func handle<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let http = response as? HTTPURLResponse else { throw APIError.unknown }

        if (200...299).contains(http.statusCode) {
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                if let wrapped = try? JSONDecoder().decode(ApiResponse<T>.self, from: data),
                   let inner = wrapped.data {
                    return inner
                }
                throw APIError.decoding(error)
            }
        } else if http.statusCode == 401 {
            throw APIError.unauthorized
        } else {
            let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            let code = json?["code"] as? String
            let message = json?["message"] as? String ?? json?["error"] as? String
            throw APIError.server(status: http.statusCode, code: code, message: message)
        }
    }
}
