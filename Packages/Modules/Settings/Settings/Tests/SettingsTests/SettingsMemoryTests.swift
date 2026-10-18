import Foundation
@testable import Settings
import Testing
import UIKit

@MainActor
@Test func settingsScreenReleasesOwnedObjects() {
    weak var weakController: SettingsViewController?
    weak var weakViewModel: SettingsViewModel?
    weak var weakCoordinator: SettingsCoordinator?

    autoreleasepool {
        let coordinator = SettingsCoordinator()
        let viewModel = SettingsViewModel(coordinator: coordinator)
        let controller = SettingsViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.loadViewIfNeeded()
        controller.loadViewIfNeeded()
        _ = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        weakController = controller
        weakViewModel = viewModel
        weakCoordinator = coordinator
    }

    #expect(weakController == nil)
    #expect(weakViewModel == nil)
    #expect(weakCoordinator == nil)
}
