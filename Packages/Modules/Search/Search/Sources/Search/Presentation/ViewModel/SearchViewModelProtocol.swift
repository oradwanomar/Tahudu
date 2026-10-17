import Combine

public enum SearchLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

@MainActor
public protocol SearchViewModelProtocol: ObservableObject {
    var state: SearchLoadState { get }
    var searchText: String { get set }
    var listings: [ListingDisplayModel] { get }

    func load() async
    func retry() async
    func submitSearch()
    func logAction(_ action: String, listingID: String?)
}
