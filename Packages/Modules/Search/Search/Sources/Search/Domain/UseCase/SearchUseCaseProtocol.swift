public protocol SearchUseCaseProtocol {
    func fetchListings() async throws -> [Listing]
    func search(_ listings: [Listing], query: String) -> [Listing]
}
