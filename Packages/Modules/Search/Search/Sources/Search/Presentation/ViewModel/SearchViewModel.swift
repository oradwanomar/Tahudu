import AnalyticsInterface
import Combine
import Foundation

@MainActor
public final class SearchViewModel: SearchViewModelProtocol {
    @Published public private(set) var state: SearchLoadState = .idle
    @Published public private(set) var listings: [ListingDisplayModel] = []
    @Published public private(set) var sortOrder: ListingSortOrder = .latest
    @Published public private(set) var favoriteIDs: Set<String> = []
    @Published public private(set) var favoritesOnly = false
    @Published public private(set) var updatingFavoriteIDs: Set<String> = []
    @Published public private(set) var favoriteError: String?
    @Published public var searchText = "" {
        didSet {
            updateListings()
        }
    }

    private let useCase: any SearchUseCaseProtocol
    private let analytics: any AnalyticsEventTracking
    private var allListings: [ListingDisplayModel] = []
    private var hasLoaded = false

    public init(
        useCase: any SearchUseCaseProtocol,
        analytics: any AnalyticsEventTracking
    ) {
        self.useCase = useCase
        self.analytics = analytics
    }

    public func load() async {
        guard !hasLoaded, state != .loading else { return }
        state = .loading
        print("Loading listings")

        do {
            let result = try await useCase.fetchListings()
            try Task.checkCancellation()
            let restoredFavorites = try await useCase.favoriteIDs(for: result)
            try Task.checkCancellation()
            allListings = result
            favoriteIDs = restoredFavorites
            updateListings()
            hasLoaded = true
            state = .loaded
            print("Showing \(listings.count) listings")
            analytics.trackEvent(AnalyticsEvent(name: "search_listings_loaded", parameters: ["count": result.count]))
        } catch {
            if Task.isCancelled || error is CancellationError {
                state = .idle
                print("Listing request cancelled")
                return
            }
            state = .failed("We couldn't load properties. Please try again.")
            print("Listing request failed: \(error)")
            analytics.trackEvent(AnalyticsEvent(name: "search_listings_failed"))
        }
    }

    public func retry() async {
        await load()
    }

    public func submitSearch() {
        print("Searching for \(searchText)")
        analytics.trackEvent(AnalyticsEvent(name: "search_submitted", parameters: ["query": searchText]))
    }

    public func setSortOrder(_ order: ListingSortOrder) {
        guard sortOrder != order else { return }
        sortOrder = order
        updateListings()
        logAction("search_sort_selected_\(order.rawValue)", listingID: nil)
    }

    public func showFavoritesOnly(_ enabled: Bool) {
        guard favoritesOnly != enabled else { return }
        favoritesOnly = enabled
        updateListings()
        logAction(enabled ? "search_favorites_filter_enabled" : "search_favorites_filter_disabled", listingID: nil)
    }

    public func toggleFavorite(_ id: String) async {
        guard state == .loaded,
              allListings.contains(where: { $0.id == id }),
              !updatingFavoriteIDs.contains(id) else { return }

        updatingFavoriteIDs.insert(id)
        defer { updatingFavoriteIDs.remove(id) }

        do {
            let isFavorite = try await useCase.toggleFavorite(
                id: id,
                isCurrentlyFavorite: favoriteIDs.contains(id)
            )
            if isFavorite {
                favoriteIDs.insert(id)
            } else {
                favoriteIDs.remove(id)
            }
            updateListings()
            logAction(isFavorite ? "search_favorite_added" : "search_favorite_removed", listingID: id)
        } catch {
            favoriteError = "Your change could not be saved. Please try again."
            print("Could not update favorite \(id): \(error)")
        }
    }

    public func dismissFavoriteError() {
        favoriteError = nil
    }

    private func updateListings() {
        let searched = useCase.search(allListings, query: searchText)
        let filtered = favoritesOnly
            ? useCase.filterFavorites(searched, favoriteIDs: favoriteIDs)
            : searched
        switch sortOrder {
        case .latest:
            listings = filtered.sorted { $0.publishedAt > $1.publishedAt }
        case .earliest:
            listings = filtered.sorted { $0.publishedAt < $1.publishedAt }
        }
    }

    public func logAction(_ action: String, listingID: String? = nil) {
        print(listingID.map { "\(action): \($0)" } ?? action)
        var parameters: [String: Any] = [:]
        if let listingID {
            parameters["listing_id"] = listingID
        }
        analytics.trackEvent(AnalyticsEvent(name: action, parameters: parameters))
    }
}
