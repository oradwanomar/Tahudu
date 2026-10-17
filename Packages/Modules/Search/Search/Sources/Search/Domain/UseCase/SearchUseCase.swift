import Foundation

public struct SearchUseCase: SearchUseCaseProtocol {
    private let repository: any ListingRepositoryProtocol

    public init(repository: any ListingRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchListings() async throws -> [Listing] {
        try await repository.fetchListings()
    }

    public func search(_ listings: [Listing], query: String) -> [Listing] {
        let terms = query.split(whereSeparator: \.isWhitespace)
        guard !terms.isEmpty else { return listings }

        return listings.filter { listing in
            terms.allSatisfy { term in
                listing.location.range(
                    of: String(term),
                    options: [.caseInsensitive, .diacriticInsensitive]
                ) != nil
            }
        }
    }
}
