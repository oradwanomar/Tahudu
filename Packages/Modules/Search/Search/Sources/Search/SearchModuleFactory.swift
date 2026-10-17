import AnalyticsInterface
import Networking
import SwiftUI

@MainActor
public enum SearchModuleFactory {
    public static func make(
        client: any APIClientProtocol,
        analytics: any AnalyticsEventTracking
    ) -> some View {
        let repository = ListingRepository(client: client)
        let useCase = SearchUseCase(repository: repository)
        let viewModel = SearchViewModel(useCase: useCase, analytics: analytics)
        return SearchView(viewModel: viewModel)
    }
}
