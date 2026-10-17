import Foundation
@testable import Search
import Testing

@Test func searchMatchesBuildingAreaAndCityWithoutAnotherFetch() async throws {
    let repository = ListingRepositoryStub(listings: testListings)
    let useCase = SearchUseCase(repository: repository)
    let listings = try await useCase.fetchListings()

    #expect(useCase.search(listings, query: "laguna").map(\.id) == ["one"])
    #expect(useCase.search(listings, query: "lake almas").map(\.id) == ["one"])
    #expect(useCase.search(listings, query: "DUBAI").map(\.id) == ["two"])
    #expect(useCase.search(listings, query: "  marina   dubai ").map(\.id) == ["two"])
    #expect(useCase.search(listings, query: "  ").count == 2)
    #expect(useCase.search(listings, query: "Abu Dhabi").isEmpty)
    #expect(await repository.fetchCount == 1)
}

actor ListingRepositoryStub: ListingRepositoryProtocol {
    private(set) var fetchCount = 0
    let listings: [Listing]

    init(listings: [Listing]) {
        self.listings = listings
    }

    func fetchListings() async throws -> [Listing] {
        fetchCount += 1
        return listings
    }
}

let testListings = [
    Listing(
        id: "one", type: "Apartment", deliveryYear: 2022, price: 2_575_000,
        currency: "AED", priceInclusive: true,
        location: "Laguna Tower, Lake Almas West, Jumeirah Lake Tower",
        bedrooms: nil, bathrooms: 1, areaSqft: 1356,
        publishedAt: Date(timeIntervalSince1970: 1_732_752_000),
        lastContactedAt: nil, tags: ["verified"],
        images: ["first_image"], contactOptions: ["phone"]
    ),
    Listing(
        id: "two", type: "Apartment", deliveryYear: 2023, price: 1_850_000,
        currency: "AED", priceInclusive: false,
        location: "Marina Heights, Dubai Marina",
        bedrooms: 1, bathrooms: 2, areaSqft: 980,
        publishedAt: Date(timeIntervalSince1970: 1_732_924_800),
        lastContactedAt: nil, tags: [],
        images: ["second_image"], contactOptions: ["email"]
    ),
]
