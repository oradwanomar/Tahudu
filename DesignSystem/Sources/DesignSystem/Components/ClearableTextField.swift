import SwiftUI

public struct ClearableTextField: View {
    @State private var editing = false

    private let label: String
    private let symbol: String?
    @Binding private var text: String
    private let onEditingChanged: ((Bool) -> Void)?

    public init(
        label: String,
        symbol: String? = nil,
        text: Binding<String>,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self.label = label
        self.symbol = symbol
        _text = text
        self.onEditingChanged = onEditingChanged
    }

    public var body: some View {
        TextField(label, text: $text, onEditingChanged: { editing in
            self.editing = editing
            onEditingChanged?(editing)
        })
        .textFieldStyle(ClearableTextFieldStyle(text: $text, symbol: symbol, focused: $editing))
    }
}

private struct ClearableTextFieldStyle: TextFieldStyle {
    @Binding var text: String
    let symbol: String?
    @Binding var focused: Bool

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .modifier(TextFieldClearButton(text: $text, symbol: symbol))
            .multilineTextAlignment(.leading)
            .padding(DSSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.medium)
                    .stroke(focused ? DSColor.accent : DSColor.border, lineWidth: 1)
            )
    }
}

private struct TextFieldClearButton: ViewModifier {
    @Environment(\.layoutDirection) private var direction
    @Binding var text: String
    let symbol: String?

    func body(content: Content) -> some View {
        HStack(spacing: DSSpacing.xSmall) {
            if let symbol {
                Image(systemName: symbol)
                    .foregroundColor(.secondary)
            }

            content

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: direction == .leftToRight ? "delete.left" : "delete.right")
                        .foregroundColor(DSColor.accent)
                }
                .accessibilityLabel("Clear text")
            }
        }
    }
}
