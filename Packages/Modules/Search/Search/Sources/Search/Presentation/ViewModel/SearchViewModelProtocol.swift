import Combine

public enum SearchLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

public enum ListingSortOrder: String, Equatable {
    case latest
    case earliest
}

@MainActor
public protocol SearchViewModelProtocol: ObservableObject {
    var state: SearchLoadState { get }
    var searchText: String { get set }
    var listings: [ListingDisplayModel] { get }
    var sortOrder: ListingSortOrder { get }

    func load() async
    func retry() async
    func submitSearch()
    func setSortOrder(_ order: ListingSortOrder)
    func logAction(_ action: String, listingID: String?)
}
