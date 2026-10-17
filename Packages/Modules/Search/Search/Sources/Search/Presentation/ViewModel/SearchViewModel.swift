import AnalyticsInterface
import Combine
import Foundation

@MainActor
public final class SearchViewModel: SearchViewModelProtocol {
    @Published public private(set) var state: SearchLoadState = .idle
    @Published public private(set) var listings: [ListingDisplayModel] = []
    @Published public private(set) var sortOrder: ListingSortOrder = .latest
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
            allListings = result
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

    private func updateListings() {
        let filtered = useCase.search(allListings, query: searchText)
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
