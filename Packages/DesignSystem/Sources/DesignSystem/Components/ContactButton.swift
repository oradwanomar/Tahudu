import SwiftUI

public struct ContactButton: View {
    private let type: ContactType
    private let action: () -> Void

    public init(_ type: ContactType, action: @escaping () -> Void) {
        self.type = type
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(
                imageSystemName: type.imageSystemNameFilled,
                imageName: type.imageNameFilled,
                bundle: .module
            )
        }
        .buttonStyle(ContactButtonStyle(type: type))
    }
}

private struct ContactButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    let type: ContactType

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: DSSize.contactButton, height: DSSize.contactButton)
            .foregroundColor(.white)
            .background(!isEnabled || configuration.isPressed ? type.backgroundColor.opacity(0.25) : type.backgroundColor)
            .cornerRadius(DSRadius.small)
    }
}
