import Foundation

public protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: any APIEndpointProtocol) async throws -> T

    func requestVoid(_ endpoint: any APIEndpointProtocol) async throws
}
