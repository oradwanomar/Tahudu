import Foundation

public struct ListingDisplayModel: Equatable, Identifiable, Sendable {
    public let id: String
    public let type: String
    public let deliveryText: String
    public let priceText: String
    public let location: String
    public let bedroomText: String
    public let bathroomText: String
    public let areaText: String
    public let publishedText: String
    public let publishedAt: Date
    public let lastContactedText: String?
    public let tags: [ListingTag]
    public let imageNames: [String]
    public let contactOptions: [ListingContactOption]

    public init(
        id: String,
        type: String,
        deliveryText: String,
        priceText: String,
        location: String,
        bedroomText: String,
        bathroomText: String,
        areaText: String,
        publishedText: String,
        publishedAt: Date,
        lastContactedText: String?,
        tags: [ListingTag],
        imageNames: [String],
        contactOptions: [ListingContactOption]
    ) {
        self.id = id
        self.type = type
        self.deliveryText = deliveryText
        self.priceText = priceText
        self.location = location
        self.bedroomText = bedroomText
        self.bathroomText = bathroomText
        self.areaText = areaText
        self.publishedText = publishedText
        self.publishedAt = publishedAt
        self.lastContactedText = lastContactedText
        self.tags = tags
        self.imageNames = imageNames
        self.contactOptions = contactOptions
    }
}

public struct ListingTag: Equatable, Sendable {
    public let title: String
    public let isVerified: Bool

    public init(title: String, isVerified: Bool) {
        self.title = title
        self.isVerified = isVerified
    }
}

public enum ListingContactOption: String, Sendable {
    case phone
    case email
    case whatsapp
}
