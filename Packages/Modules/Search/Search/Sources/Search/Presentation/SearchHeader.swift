import DesignSystem
import SwiftUI

struct SearchHeader: View {
    @Binding var text: String
    let onSubmit: () -> Void
    let onFilter: () -> Void
    let onSort: () -> Void
    let onFavorites: () -> Void

    var body: some View {
        VStack(spacing: DSSpacing.medium) {
            HStack(spacing: DSSpacing.medium) {
                toolbarButton("slider.horizontal.3", label: "Filters", action: onFilter)
                toolbarButton("arrow.up.arrow.down", label: "Sort", action: onSort)
                Spacer()
                toolbarButton("star", label: "Favorites", action: onFavorites)
            }

            HStack(spacing: DSSpacing.small) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
                searchField
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .font(.body)
            .padding(DSSpacing.medium)
            .frame(minHeight: 52)
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.large)
                    .stroke(DSColor.border, lineWidth: 1)
            )
        }
        .padding(.horizontal, DSSpacing.medium)
        .padding(.top, DSSpacing.xSmall)
        .padding(.bottom, DSSpacing.medium)
        .background(Color(UIColor.systemBackground))
    }

    @ViewBuilder
    private var searchField: some View {
        if #available(iOS 15, *) {
            TextField("City, area or building", text: $text)
                .onSubmit(onSubmit)
                .accessibilityLabel("Search by city, area or building")
        } else {
            TextField("City, area or building", text: $text, onCommit: onSubmit)
                .accessibilityLabel("Search by city, area or building")
        }
    }

    private func toolbarButton(
        _ symbol: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundColor(DSColor.accent)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(label)
        .accessibilityHint("This action will be available in a later update")
    }
}
