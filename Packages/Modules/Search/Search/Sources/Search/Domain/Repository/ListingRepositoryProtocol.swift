public protocol ListingRepositoryProtocol {
    func fetchListings() async throws -> [Listing]
}
