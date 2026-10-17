import DesignSystem
import SwiftUI

struct ListingImageCarousel: View {
    let listing: Listing
    let onFavorite: () -> Void

    @State private var selectedImage: String

    init(listing: Listing, onFavorite: @escaping () -> Void) {
        self.listing = listing
        self.onFavorite = onFavorite
        _selectedImage = State(initialValue: listing.images.first ?? "")
    }

    var body: some View {
        ZStack(alignment: .top) {
            if listing.images.isEmpty {
                Color(UIColor.secondarySystemBackground)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(.secondary)
                    )
            } else {
                TabView(selection: $selectedImage) {
                    ForEach(listing.images, id: \.self) { name in
                        Image(assetName(for: name), bundle: .main)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .tag(name)
                            .accessibilityLabel("Property photo")
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DSSpacing.xxSmall) {
                    ForEach(listing.tags, id: \.self) { tag in
                        Text(label(for: tag))
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, DSSpacing.xSmall)
                            .padding(.vertical, DSSpacing.xxSmall)
                            .background(badgeColor(for: tag))
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.small))
                    }
                }
                Spacer()
                Button(action: onFavorite) {
                    Image(systemName: "heart")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.black.opacity(0.45)))
                }
                .accessibilityLabel("Add property to favorites")
                .accessibilityHint("Favorites will be available in a later update")
            }
            .padding(DSSpacing.small)

            if listing.images.count > 1 {
                HStack(spacing: DSSpacing.xxSmall) {
                    ForEach(listing.images, id: \.self) { name in
                        Circle()
                            .fill(name == selectedImage ? Color.white : Color.white.opacity(0.6))
                            .frame(width: 7, height: 7)
                    }
                }
                .padding(DSSpacing.xSmall)
                .background(Capsule().fill(Color.black.opacity(0.3)))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, DSSpacing.xSmall)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
        }
        .frame(height: DSSize.listingImageHeight)
        .clipped()
    }

    private func assetName(for name: String) -> String {
        switch name {
        case "first_image": return "FirstImage"
        case "second_image": return "SecondImage"
        default: return name
        }
    }

    private func label(for tag: String) -> String {
        tag.replacingOccurrences(of: "_", with: " ").uppercased()
    }

    private func badgeColor(for tag: String) -> Color {
        tag == "verified" ? DSColor.verified : DSColor.accent
    }
}
