import UIKit

@MainActor
public protocol SettingsCoordinatorProtocol: AnyObject {
    func navigate(to action: SettingsAction)
}

@MainActor
public final class SettingsCoordinator: SettingsCoordinatorProtocol {
    public init() {}

    public func navigate(to action: SettingsAction) {
        switch action {
        case .language:
            openSystemSettings()
        case .country:
            showCountrySelectionScreen()
        case .notifications:
            showNotificationScreen()
        case .about:
            showAboutScreen()
        case .feedback:
            showFeedbackScreen()
        }
    }
}

private extension SettingsCoordinator {
    func openSystemSettings() {
        print(#function)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func showCountrySelectionScreen() {
        print(#function)
    }

    func showNotificationScreen() {
        print(#function)
    }

    func showAboutScreen() {
        print(#function)
    }

    func showFeedbackScreen() {
        print(#function)
    }
}
