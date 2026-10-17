import Caching
import Foundation
import Networking

public struct ListingRepository: ListingRepositoryProtocol {
    private let client: any APIClientProtocol
    private let cache: any CacheManagerProtocol
    private let cacheKey = "search.listings"

    public init(client: any APIClientProtocol, cache: any CacheManagerProtocol) {
        self.client = client
        self.cache = cache
    }

    public func fetchListings() async throws -> [Listing] {
        do {
            let response: ListingResponse = try await client.request(SearchRouter.getList)
            let listings = response.listings.map(\.listing)
            if let data = try? JSONEncoder().encode(listings) {
                try? await cache.save(data, forKey: cacheKey)
            }
            print("Loaded \(listings.count) listings")
            return listings
        } catch {
            if error is CancellationError || Task.isCancelled {
                throw error
            }
            if let data = try? await cache.data(forKey: cacheKey),
               let listings = try? JSONDecoder().decode([Listing].self, from: data) {
                print("Loaded \(listings.count) cached listings")
                return listings
            }
            throw error
        }
    }
}
