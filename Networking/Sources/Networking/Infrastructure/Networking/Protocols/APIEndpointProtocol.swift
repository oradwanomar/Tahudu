import Foundation

public protocol APIEndpointProtocol {
    var method: HTTPMethod { get }
    var path: String { get }
    var baseURL: String { get }
    var headers: [String: String] { get }
    var urlParams: [String: String] { get }
    var body: [String: Any] { get }
    var requiresAuth: Bool { get }
}

public extension APIEndpointProtocol {
    var baseURL: String {
        APIConstants.baseURL
    }

    var headers: [String: String] {
        [:]
    }

    var urlParams: [String: String] {
        [:]
    }

    var body: [String: Any] {
        [:]
    }

    var requiresAuth: Bool {
        false
    }

    func asURLRequest() throws -> URLRequest {
        guard let base = URL(string: baseURL),
              let scheme = base.scheme?.lowercased(),
              ["https", "http"].contains(scheme),
              base.host != nil else {
            throw APIClientError.invalidURL
        }

        let url = path.isEmpty ? base : base.appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIClientError.invalidURL
        }

        if !urlParams.isEmpty {
            components.queryItems = (components.queryItems ?? []) + urlParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let requestURL = components.url else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        if !body.isEmpty {
            guard JSONSerialization.isValidJSONObject(body) else {
                throw APIClientError.invalidBody
            }
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        return request
    }
}
