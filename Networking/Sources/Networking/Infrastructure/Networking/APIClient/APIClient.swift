import Foundation

public final class APIClient: APIClientProtocol {
    public static let shared = APIClient()

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func request<T: Decodable>(
        _ endpoint: any APIEndpointProtocol,
        decoder: JSONDecoder
    ) async throws -> T {
        let data = try await performRequest(endpoint)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIClientError.decodingFailed(error)
        }
    }

    public func requestVoid(_ endpoint: any APIEndpointProtocol) async throws {
        try await performRequest(endpoint)
    }

    @discardableResult
    private func performRequest(_ endpoint: any APIEndpointProtocol) async throws -> Data {
        var request = try endpoint.asURLRequest()

        if endpoint.requiresAuth {
            let authorization = request.value(forHTTPHeaderField: "Authorization")
            guard let authorization, !authorization.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw APIClientError.unauthorized
            }
        }

        if request.value(forHTTPHeaderField: "Accept") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        if request.httpBody != nil, request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let data: Data
        let response: URLResponse

        do {
            if #available(iOS 15, macOS 12, *) {
                (data, response) = try await session.data(for: request)
            } else {
                (data, response) = try await withCheckedThrowingContinuation { continuation in
                    session.dataTask(with: request) { data, response, error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else if let data, let response {
                            continuation.resume(returning: (data, response))
                        } else {
                            continuation.resume(throwing: URLError(.badServerResponse))
                        }
                    }.resume()
                }
            }
        } catch let error as URLError {
            throw APIClientError.networkError(error)
        } catch {
            throw APIClientError.requestFailed(error)
        }

        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse(data)
        }

        guard (200 ... 299).contains(response.statusCode) else {
            if response.statusCode == 401 {
                throw APIClientError.unauthorized
            }

            if let errorBody = try? JSONDecoder().decode(APIErrorBody.self, from: data),
               !errorBody.message.isEmpty {
                throw APIClientError.apiError(message: errorBody.message)
            }

            throw APIClientError.statusCode(response.statusCode)
        }

        return data
    }
}

private struct APIErrorBody: Decodable {
    let message: String
}
