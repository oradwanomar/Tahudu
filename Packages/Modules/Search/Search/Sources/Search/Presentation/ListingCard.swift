import DesignSystem
import Foundation
import SwiftUI

struct ListingCard: View {
    let listing: Listing
    let onAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ListingImageCarousel(listing: listing) {
                onAction("search_favorite_tapped")
            }

            VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
                HStack(spacing: DSSpacing.xSmall) {
                    Text(listing.type)
                        .foregroundColor(.secondary)
                    Text("Delivery: \(String(listing.deliveryYear))")
                        .foregroundColor(DSColor.deliveryText)
                        .padding(.horizontal, DSSpacing.xSmall)
                        .padding(.vertical, DSSpacing.xxSmall)
                        .background(DSColor.deliveryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.large))
                }
                .font(.caption)

                Text(priceText)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityLabel("Price \(priceText)")

                Text(listing.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: DSSpacing.medium) {
                    Label(bedroomText, systemImage: "bed.double")
                    Label("\(listing.bathrooms) Baths", systemImage: "bathtub")
                    Text("\(listing.areaSqft) sqft")
                }
                .font(.caption)
                .foregroundColor(.primary)
                .accessibilityElement(children: .combine)
            }
            .padding(DSSpacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            HStack(spacing: DSSpacing.xSmall) {
                Text(publishedText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: DSSpacing.xxSmall)
                ForEach(availableContacts, id: \.rawValue) { contact in
                    ContactButton(contact.buttonType) {
                        onAction("search_contact_\(contact.rawValue)_tapped")
                    }
                    .accessibilityLabel("Contact by \(contact.accessibilityName)")
                }
            }
            .padding(DSSpacing.small)

            if let lastContactedAt = listing.lastContactedAt {
                Label("Last contacted: \(dateText(lastContactedAt))", systemImage: "phone.fill")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DSSpacing.small)
                    .padding(.vertical, DSSpacing.xxSmall)
                    .background(DSColor.lastContactedBackground)
            }
        }
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.xLarge))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.xLarge)
                .stroke(DSColor.border, lineWidth: 1)
        )
    }

    private var priceText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let amount = formatter.string(from: NSNumber(value: listing.price)) ?? String(listing.price)
        return "\(amount) \(listing.currency)"
    }

    private var bedroomText: String {
        listing.bedrooms.map { "\($0) Beds" } ?? "Studio"
    }

    private var publishedText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "Published \(formatter.localizedString(for: listing.publishedAt, relativeTo: Date()))"
    }

    private func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private var availableContacts: [ListingContact] {
        listing.contactOptions.compactMap(ListingContact.init(rawValue:))
    }
}

private enum ListingContact: String {
    case phone
    case email
    case whatsapp

    var buttonType: ContactType {
        switch self {
        case .phone: return .phone
        case .email: return .email
        case .whatsapp: return .whatsApp
        }
    }

    var accessibilityName: String {
        switch self {
        case .phone: return "phone"
        case .email: return "email"
        case .whatsapp: return "WhatsApp"
        }
    }
}
