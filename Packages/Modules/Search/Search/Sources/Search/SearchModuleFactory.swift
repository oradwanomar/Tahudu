import AnalyticsInterface
import Caching
import Networking
import SwiftUI

@MainActor
public enum SearchModuleFactory {
    public static func make(
        client: any APIClientProtocol = APIClient.shared,
        cache: any CacheManagerProtocol = CacheManager(),
        analytics: any AnalyticsEventTracking
    ) -> some View {
        let repository = ListingRepository(client: client, cache: cache)
        let favorites = FavoriteRepository(cache: cache)
        let useCase = SearchUseCase(repository: repository, favorites: favorites)
        let viewModel = SearchViewModel(useCase: useCase, analytics: analytics)
        return SearchView(viewModel: viewModel)
    }
}
