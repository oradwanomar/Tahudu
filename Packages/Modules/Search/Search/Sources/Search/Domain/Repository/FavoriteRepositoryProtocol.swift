public protocol FavoriteRepositoryProtocol {
    func favoriteIDs(for listingIDs: [String]) async throws -> Set<String>
    func setFavorite(_ isFavorite: Bool, for listingID: String) async throws
}
