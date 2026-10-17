import Foundation
import Networking

public struct ListingRepository: ListingRepositoryProtocol {
    private let client: any APIClientProtocol

    public init(client: any APIClientProtocol) {
        self.client = client
    }

    public func fetchListings() async throws -> [Listing] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response: ListingResponse = try await client.request(SearchRouter(), decoder: decoder)
        print("Loaded \(response.listings.count) listings")
        return response.listings
    }
}

private struct ListingResponse: Decodable {
    let listings: [Listing]
}
