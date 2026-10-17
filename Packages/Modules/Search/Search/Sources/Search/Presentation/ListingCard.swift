import DesignSystem
import SwiftUI

struct ListingCard: View {
    let listing: ListingDisplayModel
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
                    Text(listing.deliveryText)
                        .foregroundColor(DSColor.deliveryText)
                        .padding(.horizontal, DSSpacing.xSmall)
                        .padding(.vertical, DSSpacing.xxSmall)
                        .background(DSColor.deliveryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.large))
                }
                .font(.caption)

                Text(listing.priceText)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityLabel("Price \(listing.priceText)")

                Text(listing.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: DSSpacing.medium) {
                    Label(listing.bedroomText, systemImage: "bed.double")
                    Label(listing.bathroomText, systemImage: "bathtub")
                    Text(listing.areaText)
                }
                .font(.caption)
                .foregroundColor(.primary)
                .accessibilityElement(children: .combine)
            }
            .padding(DSSpacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            HStack(spacing: DSSpacing.xSmall) {
                Text(listing.publishedText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: DSSpacing.xxSmall)
                ForEach(listing.contactOptions, id: \.rawValue) { contact in
                    ContactButton(contact.buttonType) {
                        onAction("search_contact_\(contact.rawValue)_tapped")
                    }
                    .accessibilityLabel("Contact by \(contact.accessibilityName)")
                }
            }
            .padding(DSSpacing.small)

            if let lastContactedText = listing.lastContactedText {
                Label(lastContactedText, systemImage: "phone.fill")
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
}

private extension ListingContactOption {
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
