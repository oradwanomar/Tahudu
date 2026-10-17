import Caching

public struct FavoriteRepository: FavoriteRepositoryProtocol {
    private let cache: any CacheManagerProtocol

    public init(cache: any CacheManagerProtocol) {
        self.cache = cache
    }

    public func favoriteIDs(for listingIDs: [String]) async throws -> Set<String> {
        var favorites: Set<String> = []
        for id in Set(listingIDs) {
            if try await cache.value(forKey: key(for: id), as: Bool.self) == true {
                favorites.insert(id)
            }
        }
        return favorites
    }

    public func setFavorite(_ isFavorite: Bool, for listingID: String) async throws {
        if isFavorite {
            try await cache.save(true, forKey: key(for: listingID))
        } else {
            try await cache.remove(forKey: key(for: listingID))
        }
    }

    private func key(for listingID: String) -> String {
        "search.favorite.\(listingID)"
    }
}
