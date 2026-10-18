import SwiftUI

public struct SearchHeader: View {
    @Binding private var text: String
    private let onSubmit: () -> Void
    private let favoritesOnly: Bool
    private let onShowAll: () -> Void
    private let onShowFavorites: () -> Void
    private let sortByLatest: Bool
    private let onSortLatest: () -> Void
    private let onSortEarliest: () -> Void

    public init(
        text: Binding<String>,
        onSubmit: @escaping () -> Void,
        favoritesOnly: Bool,
        onShowAll: @escaping () -> Void,
        onShowFavorites: @escaping () -> Void,
        sortByLatest: Bool,
        onSortLatest: @escaping () -> Void,
        onSortEarliest: @escaping () -> Void
    ) {
        _text = text
        self.onSubmit = onSubmit
        self.favoritesOnly = favoritesOnly
        self.onShowAll = onShowAll
        self.onShowFavorites = onShowFavorites
        self.sortByLatest = sortByLatest
        self.onSortLatest = onSortLatest
        self.onSortEarliest = onSortEarliest
    }

    public var body: some View {
        VStack(spacing: DSSpacing.medium) {
            HStack(spacing: DSSpacing.medium) {
                Menu {
                    Button(action: onShowAll) {
                        if favoritesOnly {
                            Text("All properties")
                        } else {
                            Label("All properties", systemImage: "checkmark")
                        }
                    }
                    Button(action: onShowFavorites) {
                        if favoritesOnly {
                            Label("Favorites only", systemImage: "checkmark")
                        } else {
                            Text("Favorites only")
                        }
                    }
                } label: {
                    toolbarIcon("slider.horizontal.3")
                }
                .accessibilityLabel("Filter listings")
                .accessibilityValue(favoritesOnly ? "Favorites only" : "All properties")
                Menu {
                    Button(action: onSortLatest) {
                        if sortByLatest {
                            Label("Latest", systemImage: "checkmark")
                        } else {
                            Text("Latest")
                        }
                    }
                    Button(action: onSortEarliest) {
                        if sortByLatest {
                            Text("Earliest")
                        } else {
                            Label("Earliest", systemImage: "checkmark")
                        }
                    }
                } label: {
                    toolbarIcon("arrow.up.arrow.down")
                }
                .accessibilityLabel("Sort listings")
                .accessibilityValue(sortByLatest ? "Latest first" : "Earliest first")
                Spacer()
                Button(action: favoritesOnly ? onShowAll : onShowFavorites) {
                    toolbarIcon(favoritesOnly ? "star.fill" : "star")
                }
                .accessibilityLabel(favoritesOnly ? "Show all properties" : "Show favorites only")
                .accessibilityIdentifier("search.favorites.toggle")
            }

            HStack(spacing: DSSpacing.small) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
                SearchTextField(text: $text, onSubmit: onSubmit)
                    .frame(height: 24)
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

            if favoritesOnly {
                Button(action: onShowAll) {
                    HStack(spacing: DSSpacing.xSmall) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Favorites only")
                            .foregroundColor(.black)
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.black)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(DSColor.accent)
                    .padding(.horizontal, DSSpacing.small)
                    .padding(.vertical, DSSpacing.xSmall)
                    .background(DSColor.deliveryBackground)
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("Clear favorites filter")
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, DSSpacing.medium)
        .padding(.top, DSSpacing.xSmall)
        .padding(.bottom, DSSpacing.medium)
        .background(Color(UIColor.systemBackground))
    }

    private func toolbarIcon(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.title3)
            .foregroundColor(DSColor.accent)
            .frame(width: 44, height: 44)
    }
}

private struct SearchTextField: UIViewRepresentable {
    @Binding var text: String
    let onSubmit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.placeholder = "City, area or building"
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.returnKeyType = .search
        field.accessibilityLabel = "Search by city, area or building"
        field.accessibilityIdentifier = "search.query"
        field.delegate = context.coordinator
        field.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.dismissKeyboard)),
        ]
        field.inputAccessoryView = toolbar
        context.coordinator.field = field
        return field
    }

    func updateUIView(_ field: UITextField, context: Context) {
        if field.text != text {
            field.text = text
        }
        context.coordinator.onSubmit = onSubmit
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var onSubmit: () -> Void
        weak var field: UITextField?

        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            _text = text
            self.onSubmit = onSubmit
        }

        @objc func textChanged(_ field: UITextField) {
            text = field.text ?? ""
        }

        @objc func dismissKeyboard() {
            field?.resignFirstResponder()
        }

        func textFieldShouldReturn(_ field: UITextField) -> Bool {
            onSubmit()
            field.resignFirstResponder()
            return true
        }
    }
}
