public protocol SearchUseCaseProtocol {
    func fetchListings() async throws -> [ListingDisplayModel]
    func search(_ listings: [ListingDisplayModel], query: String) -> [ListingDisplayModel]
    func favoriteIDs(for listings: [ListingDisplayModel]) async throws -> Set<String>
    func toggleFavorite(id: String, isCurrentlyFavorite: Bool) async throws -> Bool
    func filterFavorites(_ listings: [ListingDisplayModel], favoriteIDs: Set<String>) -> [ListingDisplayModel]
}
