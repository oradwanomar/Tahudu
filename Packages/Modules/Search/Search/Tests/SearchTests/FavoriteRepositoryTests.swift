import Caching
import Foundation
@testable import Search
import Testing

@Test func favoriteRepositoryPersistsPerListingAcrossCoreDataManagers() async throws {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathComponent("Favorites.sqlite")
    defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

    let first = FavoriteRepository(cache: CacheManager(strategy: .data(storeURL: url)))
    try await first.setFavorite(true, for: "one")
    try await first.setFavorite(true, for: "two")

    let second = FavoriteRepository(cache: CacheManager(strategy: .data(storeURL: url)))
    #expect(try await second.favoriteIDs(for: ["one", "two", "three"]) == ["one", "two"])

    try await second.setFavorite(false, for: "one")
    let third = FavoriteRepository(cache: CacheManager(strategy: .data(storeURL: url)))
    #expect(try await third.favoriteIDs(for: ["one", "two"]) == ["two"])
}
