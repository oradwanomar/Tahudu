import Foundation

public struct SearchUseCase: SearchUseCaseProtocol {
    private let repository: any ListingRepositoryProtocol

    public init(repository: any ListingRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchListings() async throws -> [ListingDisplayModel] {
        let listings = try await repository.fetchListings()
        let now = Date()
        return listings.map { map($0, relativeTo: now) }
    }

    public func search(_ listings: [ListingDisplayModel], query: String) -> [ListingDisplayModel] {
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

    private func map(_ listing: Listing, relativeTo now: Date) -> ListingDisplayModel {
        let priceFormatter = NumberFormatter()
        priceFormatter.locale = Locale(identifier: "en_US")
        priceFormatter.numberStyle = .decimal
        priceFormatter.maximumFractionDigits = 0
        let price = priceFormatter.string(from: NSNumber(value: listing.price)) ?? String(listing.price)

        let relativeDateFormatter = RelativeDateTimeFormatter()
        relativeDateFormatter.unitsStyle = .full

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        return ListingDisplayModel(
            id: listing.id,
            type: listing.type,
            deliveryText: "Delivery: \(listing.deliveryYear)",
            priceText: "\(price) \(listing.currency)",
            location: listing.location,
            bedroomText: listing.bedrooms.map { "\($0) Beds" } ?? "Studio",
            bathroomText: "\(listing.bathrooms) Baths",
            areaText: "\(listing.areaSqft) sqft",
            publishedText: "Published \(relativeDateFormatter.localizedString(for: listing.publishedAt, relativeTo: now))",
            lastContactedText: listing.lastContactedAt.map { "Last contacted: \(dateFormatter.string(from: $0))" },
            tags: listing.tags.map {
                ListingTag(
                    title: $0.replacingOccurrences(of: "_", with: " ").uppercased(),
                    isVerified: $0 == "verified"
                )
            },
            imageNames: listing.images.map { imageName(for: $0) },
            contactOptions: listing.contactOptions.compactMap(ListingContactOption.init(rawValue:))
        )
    }

    private func imageName(for value: String) -> String {
        switch value {
        case "first_image": "FirstImage"
        case "second_image": "SecondImage"
        default: value
        }
    }
}
