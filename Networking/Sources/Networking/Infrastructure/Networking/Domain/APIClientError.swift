import Foundation

public enum APIClientError: Error {
    case unauthorized
    case invalidURL
    case invalidBody
    case invalidResponse(Data)
    case requestFailed(any Error)
    case decodingFailed(any Error)
    case notExpectedHttpResponseCode(code: Int)
    case urlRequestIsEmpty
    case statusCode(Int)
    case networkError(any Error)
    case apiError(message: String)
}
