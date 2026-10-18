import Analytics
import AnalyticsInterface
import Caching
import Networking
import Search
import Settings
import SwiftUI

struct AppCompositionRoot {
    private let analytics: any AnalyticsEventTracking
    private let client: any APIClientProtocol
    private let cache: any CacheManagerProtocol

    init(
        analytics: any AnalyticsEventTracking = AnalyticsEventTracker(),
        client: any APIClientProtocol = APIClient.shared,
        cache: any CacheManagerProtocol = CacheManager()
    ) {
        self.analytics = analytics
        self.client = client
        self.cache = cache
    }

    @MainActor
    func makeRootView() -> some View {
        let search = SearchModuleFactory.make(client: client, cache: cache, analytics: analytics)
        let settings = SettingsModuleFactory.make(coordinator: SettingsCoordinator())

        return TahuduTabView(analytics: analytics) { tab in
            switch tab {
            case .search:
                search
            case .settings:
                settings
            }
        }
    }
}
