import AnalyticsInterface
import Caching
import Networking
import SwiftUI

@MainActor
public enum SearchModuleFactory {
    public static func make(
        client: any APIClientProtocol,
        cache: any CacheManagerProtocol,
        analytics: any AnalyticsEventTracking
    ) -> some View {
        let repository = ListingRepository(client: client, cache: cache)
        let useCase = SearchUseCase(repository: repository)
        let viewModel = SearchViewModel(useCase: useCase, analytics: analytics)
        return SearchView(viewModel: viewModel)
    }
}
