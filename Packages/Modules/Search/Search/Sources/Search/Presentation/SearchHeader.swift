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
        }
        .padding(.horizontal, DSSpacing.medium)
        .padding(.top, DSSpacing.xSmall)
        .padding(.bottom, DSSpacing.medium)
        .background(Color(UIColor.systemBackground))
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
