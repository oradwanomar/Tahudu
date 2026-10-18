@testable import DesignSystem
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
struct DesignSystemSnapshotTests {
    @Test func contactButton() {
        let view = HStack(spacing: DSSpacing.medium) {
            ContactButton(.phone) {}
            ContactButton(.email) {}
            ContactButton(.whatsApp) {}
            ContactButton(.sms) {}
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .preferredColorScheme(.light)

        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.98, layout: .fixed(width: 280, height: 88)))
    }

    @Test func clearableTextField() {
        let view = VStack(spacing: DSSpacing.medium) {
            ClearableTextField(label: "Search", symbol: "magnifyingglass", text: .constant(""))
            ClearableTextField(label: "Search", symbol: "magnifyingglass", text: .constant("Dubai Marina"))
        }
        .padding()
        .background(Color.white)
        .preferredColorScheme(.light)

        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.98, layout: .fixed(width: 390, height: 144)))
    }

    @Test func skeletonBlock() {
        let view = DSSkeletonBlock(width: 160, height: 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .preferredColorScheme(.light)

        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.98, layout: .fixed(width: 200, height: 64)))
    }

    @Test func searchHeader() {
        let all = SearchHeader(
            text: .constant(""),
            onSubmit: {},
            favoritesOnly: false,
            onShowAll: {},
            onShowFavorites: {},
            sortByLatest: true,
            onSortLatest: {},
            onSortEarliest: {}
        )
        .preferredColorScheme(.light)

        let favorites = SearchHeader(
            text: .constant("Dubai Marina"),
            onSubmit: {},
            favoritesOnly: true,
            onShowAll: {},
            onShowFavorites: {},
            sortByLatest: false,
            onSortLatest: {},
            onSortEarliest: {}
        )
        .preferredColorScheme(.light)

        assertSnapshot(of: all, as: .image(precision: 0.99, perceptualPrecision: 0.98, layout: .fixed(width: 390, height: 148)), named: "all")
        assertSnapshot(of: favorites, as: .image(precision: 0.99, perceptualPrecision: 0.98, layout: .fixed(width: 390, height: 180)), named: "favorites")
    }

    @Test func searchLoadingCard() {
        let view = SearchLoadingCard()
            .padding()
            .background(Color.white)
            .preferredColorScheme(.light)

        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.98, layout: .fixed(width: 390, height: 500)))
    }
}
