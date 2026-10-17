import AnalyticsInterface
import Foundation
@testable import Search
import Testing

@MainActor
@Test func viewModelLoadsOnceAndFiltersLocally() async {
    let repository = ListingRepositoryStub(listings: testListings)
    let analytics = AnalyticsEventTrackerMock()
    let viewModel = SearchViewModel(
        useCase: SearchUseCase(repository: repository),
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
        useCase: SearchUseCase(repository: repository),
        analytics: AnalyticsEventTrackerMock()
    )

    await viewModel.load()
    #expect(viewModel.state == .failed("We couldn't load properties. Please try again."))

    await viewModel.retry()
    #expect(viewModel.state == .loaded)
    #expect(viewModel.listings.count == 2)
}

@MainActor
@Test func cancellingLoadDoesNotShowAnError() async {
    let analytics = AnalyticsEventTrackerMock()
    let viewModel = SearchViewModel(
        useCase: SearchUseCase(repository: SlowListingRepository()),
        analytics: analytics
    )

    let task = Task { await viewModel.load() }
    task.cancel()
    await task.value

    #expect(viewModel.state == .idle)
    #expect(analytics.trackedEvents.isEmpty)
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
