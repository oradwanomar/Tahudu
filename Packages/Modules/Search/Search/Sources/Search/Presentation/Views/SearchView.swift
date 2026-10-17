import DesignSystem
import SwiftUI

@MainActor
public struct SearchView<Model: SearchViewModelProtocol>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var viewModel: Model

    public init(viewModel: @autoclosure @escaping () -> Model) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        VStack(spacing: 0) {
            SearchHeader(
                text: Binding(
                    get: { viewModel.searchText },
                    set: { viewModel.searchText = $0 }
                ),
                onSubmit: viewModel.submitSearch,
                onFilter: {
                    dismissKeyboard()
                    viewModel.logAction("search_filter_tapped", listingID: nil)
                },
                onSort: {
                    dismissKeyboard()
                    viewModel.logAction("search_sort_tapped", listingID: nil)
                },
                onFavorites: {
                    dismissKeyboard()
                    viewModel.logAction("search_favorites_tapped", listingID: nil)
                }
            )

            ScrollView {
                LazyVStack(spacing: DSSpacing.large) {
                    content
                }
                .padding(.horizontal, DSSpacing.medium)
                .padding(.top, DSSpacing.medium)
                .padding(.bottom, DSSpacing.large)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: viewModel.state)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: viewModel.listings.isEmpty)
            }
            .background(Color(UIColor.systemBackground))
            .simultaneousGesture(TapGesture().onEnded(dismissKeyboard))
        }
        .task {
            await viewModel.load()
        }
        .onDisappear {
            dismissKeyboard()
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack(spacing: DSSpacing.large) {
                ForEach(0 ..< 2, id: \.self) { _ in
                    SearchLoadingCard()
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Loading properties")
        case let .failed(message):
            SearchMessage(
                symbol: "wifi.exclamationmark",
                title: "Unable to load properties",
                message: message,
                buttonTitle: "Try again"
            ) {
                Task { await viewModel.retry() }
            }
            .transition(.opacity)
        case .loaded:
            if viewModel.listings.isEmpty {
                SearchMessage(
                    symbol: "magnifyingglass",
                    title: "No properties found",
                    message: viewModel.searchText.isEmpty
                        ? "There are no properties to show right now."
                        : "Try another city, area, or building."
                )
                .transition(.opacity)
            } else {
                ForEach(viewModel.listings) { listing in
                    ListingCard(listing: listing) { action in
                        viewModel.logAction(action, listingID: listing.id)
                    }
                }
            }
        }
    }
}

private struct SearchMessage: View {
    let symbol: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    init(
        symbol: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DSSpacing.small) {
            Image(systemName: symbol)
                .font(.title)
                .foregroundColor(DSColor.accent)
                .accessibilityHidden(true)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .font(.caption)
                    .padding(.top, DSSpacing.xSmall)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(DSSpacing.large)
    }
}
