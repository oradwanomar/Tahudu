public protocol SearchUseCaseProtocol {
    func fetchListings() async throws -> [ListingDisplayModel]
    func search(_ listings: [ListingDisplayModel], query: String) -> [ListingDisplayModel]
}
