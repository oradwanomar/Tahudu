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
                favoritesOnly: viewModel.favoritesOnly,
                onShowAll: {
                    dismissKeyboard()
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        viewModel.showFavoritesOnly(false)
                    }
                },
                onShowFavorites: {
                    dismissKeyboard()
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        viewModel.showFavoritesOnly(true)
                    }
                },
                sortByLatest: viewModel.sortOrder == .latest,
                onSortLatest: {
                    dismissKeyboard()
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                        viewModel.setSortOrder(.latest)
                    }
                },
                onSortEarliest: {
                    dismissKeyboard()
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                        viewModel.setSortOrder(.earliest)
                    }
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
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: viewModel.listings.map(\.id))
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
        .alert(
            "Could not update favorites",
            isPresented: Binding(
                get: { viewModel.favoriteError != nil },
                set: {
                    if !$0 {
                        viewModel.dismissFavoriteError()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.dismissFavoriteError()
            }
        } message: {
            Text(viewModel.favoriteError ?? "")
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
                Group {
                    if viewModel.favoritesOnly {
                        SearchMessage(
                            symbol: "heart",
                            title: "No favorites found",
                            message: viewModel.searchText.isEmpty
                                ? "Tap the heart on a property to save it here."
                                : "No saved properties match your search."
                        )
                    } else {
                        SearchMessage(
                            symbol: "magnifyingglass",
                            title: "No properties found",
                            message: viewModel.searchText.isEmpty
                                ? "There are no properties to show right now."
                                : "Try another city, area, or building."
                        )
                    }
                }
                .transition(.opacity)
            } else {
                ForEach(viewModel.listings) { listing in
                    ListingCard(
                        listing: listing,
                        isFavorite: viewModel.favoriteIDs.contains(listing.id),
                        isFavoriteUpdating: viewModel.updatingFavoriteIDs.contains(listing.id),
                        onFavorite: {
                            Task { await viewModel.toggleFavorite(listing.id) }
                        },
                        onAction: { action in
                            viewModel.logAction(action, listingID: listing.id)
                        }
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
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
                .foregroundColor(.red)
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
