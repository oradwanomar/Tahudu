#if DEBUG
    import Foundation
    import Networking

    struct UIFlowAPIClient: APIClientProtocol {
        func request<T: Decodable>(_: any APIEndpointProtocol) async throws -> T {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: Data(Self.response.utf8))
        }

        func requestVoid(_: any APIEndpointProtocol) async throws {}

        private static let response = """
        {
          "listings": [
            {
              "id": "ui_marina", "type": "Apartment", "deliveryYear": 2023,
              "price": 1850000, "currency": "AED", "priceInclusive": false,
              "location": "Marina Heights, Dubai Marina",
              "bedrooms": 1, "bathrooms": 2, "areaSqft": 980,
              "publishedAt": "2024-11-30T00:00:00Z", "lastContactedAt": null,
              "tags": ["verified"], "images": ["first_image"],
              "contactOptions": ["phone"]
            },
            {
              "id": "ui_palm", "type": "Apartment", "deliveryYear": 2022,
              "price": 2575000, "currency": "AED", "priceInclusive": true,
              "location": "Palm Residence, Palm Jumeirah",
              "bedrooms": 2, "bathrooms": 2, "areaSqft": 1356,
              "publishedAt": "2024-11-28T00:00:00Z", "lastContactedAt": null,
              "tags": ["verified"], "images": ["second_image"],
              "contactOptions": ["phone"]
            }
          ]
        }
        """
    }
#endif
