import DesignSystem
import SwiftUI

struct SettingsView: UIViewControllerRepresentable {
    let viewModel: any SettingsViewModelProtocol

    func makeUIViewController(context _: Context) -> UINavigationController {
        let settingsViewController = SettingsViewController(viewModel: viewModel)
        settingsViewController.title = "My Account"

        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.view.backgroundColor = DSUIColor.groupedBackground
        navigationController.view.tintColor = DSUIColor.accent
        return navigationController
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}
}
