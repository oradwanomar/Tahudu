import AnalyticsInterface
@testable import Search
import Testing

@MainActor
@Test func searchViewModelReleasesAfterLoading() async {
    let reference = await loadedViewModelReference()
    #expect(reference.value == nil)
}

@MainActor
private func loadedViewModelReference() async -> WeakReference<SearchViewModel> {
    let viewModel = SearchViewModel(
        useCase: SearchUseCase(
            repository: ListingRepositoryStub(listings: testListings),
            favorites: FavoriteRepositoryStub()
        ),
        analytics: AnalyticsEventTrackerMock()
    )
    await viewModel.load()
    return WeakReference(viewModel)
}

private final class WeakReference<Value: AnyObject> {
    weak var value: Value?

    init(_ value: Value) {
        self.value = value
    }
}
