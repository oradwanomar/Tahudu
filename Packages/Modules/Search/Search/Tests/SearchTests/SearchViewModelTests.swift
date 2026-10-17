import AnalyticsInterface
import Foundation
@testable import Search
import Testing

@MainActor
@Test func viewModelLoadsOnceAndFiltersLocally() async {
    let repository = ListingRepositoryStub(listings: testListings)
    let analytics = AnalyticsEventTrackerMock()
    let viewModel = SearchViewModel(
        useCase: SearchUseCase(repository: repository, favorites: FavoriteRepositoryStub()),
        analytics: analytics
    )

    await viewModel.load()
    viewModel.searchText = "Dubai Marina"
    await viewModel.load()

    #expect(viewModel.state == .loaded)
    #expect(viewModel.listings.map(\.id) == ["two"])
    #expect(await repository.fetchCount == 1)
    #expect(analytics.trackedEvents.map(\.name) == ["search_listings_loaded"])
}

@MainActor
@Test func viewModelShowsFailureAndCanRetry() async {
    let repository = FlakyListingRepository()
    let viewModel = SearchViewModel(
        useCase: SearchUseCase(repository: repository, favorites: FavoriteRepositoryStub()),
        analytics: AnalyticsEventTrackerMock()
    )

    await viewModel.load()
    #expect(viewModel.state == .failed("We couldn't load properties. Please try again."))

    await viewModel.retry()
    #expect(viewModel.state == .loaded)
    #expect(viewModel.listings.count == 2)
}

@MainActor
@Test func viewModelSortsByPublicationDateAndKeepsOrderWhileSearching() async {
    let analytics = AnalyticsEventTrackerMock()
    let viewModel = SearchViewModel(
        useCase: SearchUseCase(
            repository: ListingRepositoryStub(listings: testListings),
            favorites: FavoriteRepositoryStub()
        ),
        analytics: analytics
    )

    await viewModel.load()
    #expect(viewModel.listings.map(\.id) == ["two", "one"])

    viewModel.setSortOrder(.earliest)
    #expect(viewModel.listings.map(\.id) == ["one", "two"])

    viewModel.searchText = "Dubai"
    #expect(viewModel.listings.map(\.id) == ["two"])

    viewModel.searchText = ""
    #expect(viewModel.listings.map(\.id) == ["one", "two"])

    viewModel.setSortOrder(.latest)
    #expect(viewModel.listings.map(\.id) == ["two", "one"])
    #expect(analytics.trackedEvents.map(\.name) == [
        "search_listings_loaded",
        "search_sort_selected_earliest",
        "search_sort_selected_latest",
    ])
}

@MainActor
@Test func cancellingLoadDoesNotShowAnError() async {
    let analytics = AnalyticsEventTrackerMock()
    let viewModel = SearchViewModel(
        useCase: SearchUseCase(repository: SlowListingRepository(), favorites: FavoriteRepositoryStub()),
        analytics: analytics
    )

    let task = Task { await viewModel.load() }
    task.cancel()
    await task.value

    #expect(viewModel.state == .idle)
    #expect(analytics.trackedEvents.isEmpty)
}

@MainActor
@Test func viewModelCombinesFavoritesWithSearchAndSort() async {
    let favorites = FavoriteRepositoryStub(ids: ["one"])
    let viewModel = SearchViewModel(
        useCase: SearchUseCase(
            repository: ListingRepositoryStub(listings: testListings),
            favorites: favorites
        ),
        analytics: AnalyticsEventTrackerMock()
    )

    await viewModel.load()
    #expect(viewModel.favoriteIDs == ["one"])
    #expect(viewModel.listings.map(\.id) == ["two", "one"])

    viewModel.showFavoritesOnly(true)
    #expect(viewModel.listings.map(\.id) == ["one"])

    viewModel.searchText = "Dubai"
    #expect(viewModel.listings.isEmpty)
    viewModel.searchText = ""

    await viewModel.toggleFavorite("one")
    #expect(viewModel.favoriteIDs.isEmpty)
    #expect(viewModel.listings.isEmpty)

    viewModel.showFavoritesOnly(false)
    await viewModel.toggleFavorite("two")
    viewModel.showFavoritesOnly(true)
    #expect(viewModel.listings.map(\.id) == ["two"])
    #expect(await favorites.favoriteIDs(for: ["one", "two"]) == ["two"])
}

@MainActor
@Test func failedFavoriteWriteKeepsPreviousState() async {
    let viewModel = SearchViewModel(
        useCase: SearchUseCase(
            repository: ListingRepositoryStub(listings: testListings),
            favorites: FailingFavoriteRepository()
        ),
        analytics: AnalyticsEventTrackerMock()
    )

    await viewModel.load()
    await viewModel.toggleFavorite("one")

    #expect(viewModel.favoriteIDs.isEmpty)
    #expect(viewModel.favoriteError != nil)
    viewModel.dismissFavoriteError()
    #expect(viewModel.favoriteError == nil)
}

private actor FlakyListingRepository: ListingRepositoryProtocol {
    private var attempts = 0

    func fetchListings() async throws -> [Listing] {
        attempts += 1
        if attempts == 1 {
            throw URLError(.notConnectedToInternet)
        }
        return testListings
    }
}

private struct SlowListingRepository: ListingRepositoryProtocol {
    func fetchListings() async throws -> [Listing] {
        try await Task.sleep(nanoseconds: 5_000_000_000)
        return testListings
    }
}

private struct FailingFavoriteRepository: FavoriteRepositoryProtocol {
    func favoriteIDs(for _: [String]) -> Set<String> {
        []
    }

    func setFavorite(_: Bool, for _: String) throws {
        throw URLError(.cannotWriteToFile)
    }
}
