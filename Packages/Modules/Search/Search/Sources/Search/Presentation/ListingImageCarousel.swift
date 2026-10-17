import DesignSystem
import SwiftUI

struct ListingImageCarousel: View {
    let listing: ListingDisplayModel
    let onFavorite: () -> Void

    @State private var selectedImage: String

    init(listing: ListingDisplayModel, onFavorite: @escaping () -> Void) {
        self.listing = listing
        self.onFavorite = onFavorite
        _selectedImage = State(initialValue: listing.imageNames.first ?? "")
    }

    var body: some View {
        ZStack(alignment: .top) {
            if listing.imageNames.isEmpty {
                Color(UIColor.secondarySystemBackground)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(.secondary)
                    )
            } else {
                TabView(selection: $selectedImage) {
                    ForEach(listing.imageNames, id: \.self) { name in
                        Image(name, bundle: .main)
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
                    ForEach(listing.tags, id: \.title) { tag in
                        Text(tag.title)
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, DSSpacing.xSmall)
                            .padding(.vertical, DSSpacing.xxSmall)
                            .background(tag.isVerified ? DSColor.verified : DSColor.accent)
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

            if listing.imageNames.count > 1 {
                HStack(spacing: DSSpacing.xxSmall) {
                    ForEach(listing.imageNames, id: \.self) { name in
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
}
