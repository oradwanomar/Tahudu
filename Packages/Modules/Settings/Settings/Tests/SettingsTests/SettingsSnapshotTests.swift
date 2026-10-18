import Foundation
@testable import Settings
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
@Test func settingsViewModelProvidesSections() {
    let viewModel = SettingsViewModel(
        languageCode: "fr",
        locale: Locale(identifier: "en_US"),
        coordinator: SettingsCoordinatorSpy()
    )

    #expect(viewModel.sections.map { $0.map(\.title) } == [
        ["Language", "Country", "Notifications"],
        ["About", "Feedback"],
    ])
    #expect(viewModel.sections[0][0].detail == "French")
    #expect(viewModel.sections[0][0].accessibilityIdentifier == "SettingsCell_language")
    #expect(viewModel.sections[1][1].action == .feedback)
}

@MainActor
@Test func settingsViewModelRoutesSelections() {
    let coordinator = SettingsCoordinatorSpy()
    let viewModel = SettingsViewModel(coordinator: coordinator)

    viewModel.selectRow(0, in: 0)
    viewModel.selectRow(1, in: 0)
    viewModel.selectRow(2, in: 0)
    viewModel.selectRow(0, in: 1)
    viewModel.selectRow(1, in: 1)
    viewModel.selectRow(3, in: 0)

    #expect(coordinator.actions == [.language, .country, .notifications, .about, .feedback])
}

@MainActor
private final class SettingsCoordinatorSpy: SettingsCoordinatorProtocol {
    var actions: [SettingsAction] = []

    func navigate(to action: SettingsAction) {
        actions.append(action)
    }
}

@MainActor
struct SettingsSnapshotTests {
    @Test func settingsScreen() {
        let view = SettingsView(
            viewModel: SettingsViewModel(
                languageCode: "en",
                locale: Locale(identifier: "en_US"),
                coordinator: SettingsCoordinatorSpy()
            )
        )
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .preferredColorScheme(.light)

        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.98, layout: .fixed(width: 390, height: 720)))
    }
}
