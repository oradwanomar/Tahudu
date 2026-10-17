import Combine
@testable import Search
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
struct SearchSnapshotTests {
    @Test func listingImageCarousel() {
        let view = VStack(spacing: 16) {
            ListingImageCarousel(listing: listing, isFavorite: false, isFavoriteUpdating: false, onFavorite: {})
            ListingImageCarousel(listing: listing, isFavorite: true, isFavoriteUpdating: false, onFavorite: {})
        }
        .background(Color.white)
        .preferredColorScheme(.light)

        assertSnapshot(of: view, as: .image(layout: .fixed(width: 358, height: 464)))
    }

    @Test func listingCard() {
        let view = ListingCard(
            listing: listing,
            isFavorite: true,
            isFavoriteUpdating: false,
            onFavorite: {},
            onAction: { _ in }
        )
        .padding(16)
        .background(Color.white)
        .preferredColorScheme(.light)

        assertSnapshot(of: view, as: .image(layout: .fixed(width: 390, height: 470)))
    }

    @Test func searchView() {
        let results = SearchView(viewModel: SnapshotSearchViewModel(state: .loaded, listings: [listing]))
            .background(Color.white)
            .preferredColorScheme(.light)

        let favorites = SearchView(
            viewModel: SnapshotSearchViewModel(state: .loaded, favoritesOnly: true)
        )
        .background(Color.white)
        .preferredColorScheme(.light)

        let loading = SearchView(viewModel: SnapshotSearchViewModel(state: .loading))
            .background(Color.white)
            .preferredColorScheme(.light)

        let failed = SearchView(viewModel: SnapshotSearchViewModel(state: .failed("Please try again.")))
            .background(Color.white)
            .preferredColorScheme(.light)

        let layout = SwiftUISnapshotLayout.fixed(width: 390, height: 720)
        assertSnapshot(of: results, as: .image(layout: layout), named: "results")
        assertSnapshot(of: favorites, as: .image(layout: layout), named: "favorites-empty")
        assertSnapshot(of: loading, as: .image(layout: layout), named: "loading")
        assertSnapshot(of: failed, as: .image(layout: layout), named: "failed")
    }

    private var listing: ListingDisplayModel {
        ListingDisplayModel(
            id: "listing-1",
            type: "Apartment",
            deliveryText: "Delivery: 2022",
            priceText: "2,575,000 AED",
            location: "Dubai Marina",
            bedroomText: "Studio",
            bathroomText: "1 Bath",
            areaText: "1,356 sqft",
            publishedText: "Published 3 days ago",
            publishedAt: Date(timeIntervalSince1970: 1_732_752_000),
            lastContactedText: "Last contacted: 28 Jul 2021",
            tags: [ListingTag(title: "VERIFIED", isVerified: true)],
            imageNames: [],
            contactOptions: [.phone, .email, .whatsapp]
        )
    }
}

@MainActor
private final class SnapshotSearchViewModel: SearchViewModelProtocol {
    @Published var state: SearchLoadState
    @Published var searchText = ""
    @Published var listings: [ListingDisplayModel]
    @Published var sortOrder: ListingSortOrder = .latest
    @Published var favoriteIDs: Set<String> = []
    @Published var favoritesOnly: Bool
    @Published var updatingFavoriteIDs: Set<String> = []
    @Published var favoriteError: String?

    init(
        state: SearchLoadState,
        listings: [ListingDisplayModel] = [],
        favoritesOnly: Bool = false
    ) {
        self.state = state
        self.listings = listings
        self.favoritesOnly = favoritesOnly
    }

    func load() async {}
    func retry() async {}
    func submitSearch() {}
    func setSortOrder(_: ListingSortOrder) {}
    func showFavoritesOnly(_: Bool) {}
    func toggleFavorite(_: String) async {}
    func dismissFavoriteError() {}
    func logAction(_: String, listingID _: String?) {}
}
