import Foundation

public protocol APIClientProtocol {
    func request<T: Decodable>(
        _ endpoint: any APIEndpointProtocol,
        decoder: JSONDecoder
    ) async throws -> T

    func requestVoid(_ endpoint: any APIEndpointProtocol) async throws
}

public extension APIClientProtocol {
    func request<T: Decodable>(_ endpoint: any APIEndpointProtocol) async throws -> T {
        try await request(endpoint, decoder: JSONDecoder())
    }
}
