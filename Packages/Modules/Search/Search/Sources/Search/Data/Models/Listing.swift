import Foundation

public struct Listing: Decodable, Equatable, Identifiable, Sendable {
    public let id: String
    public let type: String
    public let deliveryYear: Int
    public let price: Int
    public let currency: String
    public let priceInclusive: Bool
    public let location: String
    public let bedrooms: Int?
    public let bathrooms: Int
    public let areaSqft: Int
    public let publishedAt: Date
    public let lastContactedAt: Date?
    public let tags: [String]
    public let images: [String]
    public let contactOptions: [String]

    public init(
        id: String,
        type: String,
        deliveryYear: Int,
        price: Int,
        currency: String,
        priceInclusive: Bool,
        location: String,
        bedrooms: Int?,
        bathrooms: Int,
        areaSqft: Int,
        publishedAt: Date,
        lastContactedAt: Date?,
        tags: [String],
        images: [String],
        contactOptions: [String]
    ) {
        self.id = id
        self.type = type
        self.deliveryYear = deliveryYear
        self.price = price
        self.currency = currency
        self.priceInclusive = priceInclusive
        self.location = location
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.areaSqft = areaSqft
        self.publishedAt = publishedAt
        self.lastContactedAt = lastContactedAt
        self.tags = tags
        self.images = images
        self.contactOptions = contactOptions
    }
}
