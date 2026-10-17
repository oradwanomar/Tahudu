import Foundation
import Networking

public struct ListingRepository: ListingRepositoryProtocol {
    private let client: any APIClientProtocol

    public init(client: any APIClientProtocol) {
        self.client = client
    }

    public func fetchListings() async throws -> [Listing] {
        let response: ListingResponse = try await client.request(SearchRouter())
        print("Loaded \(response.listings.count) listings")
        return response.listings.map(\.listing)
    }
}
