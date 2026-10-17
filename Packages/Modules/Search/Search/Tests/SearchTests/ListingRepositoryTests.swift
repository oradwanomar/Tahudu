import Foundation
import Networking
@testable import Search
import Testing

@Test func repositoryDecodesListingsAndNullableFields() async throws {
    let client = StubAPIClient(data: Data(responseJSON.utf8))
    let repository = ListingRepository(client: client)

    let listings = try await repository.fetchListings()

    #expect(listings.count == 2)
    #expect(listings[0].id == "prop_001")
    #expect(listings[0].bedrooms == nil)
    #expect(listings[0].lastContactedAt != nil)
    #expect(listings[0].images == ["first_image", "second_image"])
    #expect(listings[0].contactOptions == ["phone", "email", "whatsapp"])
    #expect(listings[1].bedrooms == 1)
    #expect(listings[1].lastContactedAt == nil)
}

@Test func repositoryPropagatesNetworkFailures() async {
    let repository = ListingRepository(client: StubAPIClient(error: URLError(.notConnectedToInternet)))

    await #expect(throws: URLError.self) {
        _ = try await repository.fetchListings()
    }
}

@Test func searchRouterUsesHostedListingsURL() throws {
    let request = try SearchRouter().asURLRequest()

    #expect(request.url?.absoluteString == "https://simplejsoncms.com/api/m6nfoc4jlw")
    #expect(request.httpMethod == "GET")
}

private struct StubAPIClient: APIClientProtocol {
    let data: Data
    let error: (any Error)?

    init(data: Data = Data(), error: (any Error)? = nil) {
        self.data = data
        self.error = error
    }

    func request<T: Decodable>(_: any APIEndpointProtocol) async throws -> T {
        if let error {
            throw error
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    func requestVoid(_: any APIEndpointProtocol) async throws {
        if let error {
            throw error
        }
    }
}

private let responseJSON = """
{
  "listings": [
    {
      "id": "prop_001", "type": "Apartment", "deliveryYear": 2022,
      "price": 2575000, "currency": "AED", "priceInclusive": true,
      "location": "Laguna Tower, Lake Almas West, Jumeirah Lake Tower",
      "bedrooms": null, "bathrooms": 1, "areaSqft": 1356,
      "publishedAt": "2024-11-28T00:00:00Z",
      "lastContactedAt": "2021-07-28T00:00:00Z",
      "tags": ["verified", "new_construction"],
      "images": ["first_image", "second_image"],
      "contactOptions": ["phone", "email", "whatsapp"]
    },
    {
      "id": "prop_002", "type": "Apartment", "deliveryYear": 2023,
      "price": 1850000, "currency": "AED", "priceInclusive": false,
      "location": "Marina Heights, Dubai Marina",
      "bedrooms": 1, "bathrooms": 2, "areaSqft": 980,
      "publishedAt": "2024-11-30T00:00:00Z", "lastContactedAt": null,
      "tags": ["verified"], "images": ["second_image", "first_image"],
      "contactOptions": ["phone", "whatsapp"]
    }
  ]
}
"""
