import Foundation
@testable import Networking
import Testing

@Suite(.serialized)
struct NetworkingTests {
    @Test func requestBuildsURLAndDecodesArray() async throws {
        let endpoint = Endpoint(
            method: .get,
            path: "items",
            baseURL: "https://example.com/api?existing=1",
            urlParams: ["page": "2"]
        )
        let recorder = RequestRecorder()
        let client = makeClient(data: Data("[1,2]".utf8), recorder: recorder)

        let values: [Int] = try await client.request(endpoint)
        #expect(values == [1, 2])

        let request = try #require(recorder.request)
        #expect(request.url?.path == "/api/items")
        let url = try #require(request.url)
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        #expect(Set(queryItems ?? []) == Set([URLQueryItem(name: "existing", value: "1"), URLQueryItem(name: "page", value: "2")]))
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
    }

    @Test func requestDecodesISO8601Dates() async throws {
        let client = makeClient(data: Data("{\"publishedAt\":\"2024-11-28T00:00:00Z\"}".utf8))

        let value: DatePayload = try await client.request(Endpoint(method: .get))

        #expect(value.publishedAt == Date(timeIntervalSince1970: 1_732_752_000))
    }

    @Test func voidRequestAcceptsEmptySuccess() async throws {
        let client = makeClient(statusCode: 204)
        try await client.requestVoid(Endpoint(method: .delete))
    }

    @Test func authorizationIsRequiredOnlyWhenRequested() async throws {
        let recorder = RequestRecorder()
        let client = makeClient(recorder: recorder)
        do {
            try await client.requestVoid(Endpoint(method: .get, requiresAuth: true))
            Issue.record("Expected unauthorized error")
        } catch APIClientError.unauthorized {
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        #expect(recorder.request == nil)

        let authorized = Endpoint(method: .get, headers: ["Authorization": "Bearer token"], requiresAuth: true)
        try await client.requestVoid(authorized)
        #expect(recorder.request?.value(forHTTPHeaderField: "Authorization") == "Bearer token")
    }

    @Test func unauthorizedResponse() async throws {
        let client = makeClient(statusCode: 401, data: Data("{\"message\":\"Expired\"}".utf8))
        do {
            try await client.requestVoid(Endpoint(method: .get))
            Issue.record("Expected unauthorized error")
        } catch APIClientError.unauthorized {
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func invalidBodyIsRejectedBeforeSending() async throws {
        let recorder = RequestRecorder()
        let client = makeClient(recorder: recorder)
        let endpoint = Endpoint(method: .post, body: ["value": Double.nan])
        do {
            try await client.requestVoid(endpoint)
            Issue.record("Expected invalid body error")
        } catch APIClientError.invalidBody {
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        #expect(recorder.request == nil)
    }

    @Test func requestSendsJSONBodyWithCustomHeaders() async throws {
        let endpoint = Endpoint(
            method: .post,
            headers: ["Accept": "application/vnd.example+json", "Content-Type": "application/custom"],
            body: ["name": "item"]
        )
        let body = try #require(endpoint.asURLRequest().httpBody)
        #expect(try JSONSerialization.jsonObject(with: body) as? [String: String] == ["name": "item"])

        let recorder = RequestRecorder()
        let client = makeClient(statusCode: 201, recorder: recorder)
        try await client.requestVoid(endpoint)

        let request = try #require(recorder.request)
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/vnd.example+json")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/custom")
    }

    @Test func serverMessageAndStatusErrors() async throws {
        let clientWithMessage = makeClient(statusCode: 422, data: Data("{\"message\":\"Invalid input\"}".utf8))
        do {
            try await clientWithMessage.requestVoid(Endpoint(method: .post))
            Issue.record("Expected API error")
        } catch let APIClientError.apiError(message) {
            #expect(message == "Invalid input")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        let clientWithoutMessage = makeClient(statusCode: 503)
        do {
            try await clientWithoutMessage.requestVoid(Endpoint(method: .get))
            Issue.record("Expected status code error")
        } catch let APIClientError.statusCode(code) {
            #expect(code == 503)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    private func makeClient(
        statusCode: Int = 200,
        data: Data = Data(),
        recorder: RequestRecorder? = nil
    ) -> APIClient {
        MockURLProtocol.handler = { request in
            recorder?.record(request)
            return (statusCode, data)
        }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return APIClient(session: URLSession(configuration: configuration))
    }
}

private struct DatePayload: Decodable {
    let publishedAt: Date
}

private struct Endpoint: APIEndpointProtocol {
    let method: HTTPMethod
    var path = ""
    var baseURL = "https://example.com/api"
    var headers: [String: String] = [:]
    var urlParams: [String: String] = [:]
    var body: [String: Any] = [:]
    var requiresAuth = false
}

private final class RequestRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var storedRequest: URLRequest?

    var request: URLRequest? {
        lock.lock()
        defer { lock.unlock() }
        return storedRequest
    }

    func record(_ request: URLRequest) {
        lock.lock()
        storedRequest = request
        lock.unlock()
    }
}

private final class MockURLProtocol: URLProtocol {
    static var handler: ((URLRequest) -> (Int, Data))?

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler,
              let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        let (status, data) = handler(request)
        guard let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
