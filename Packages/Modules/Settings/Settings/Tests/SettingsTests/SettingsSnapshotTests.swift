import Foundation
@testable import Settings
import SnapshotTesting
import SwiftUI
import Testing

@Test func settingsViewModelProvidesSections() {
    let viewModel = SettingsViewModel(languageCode: "fr", locale: Locale(identifier: "en_US"))

    #expect(viewModel.sections.map { $0.map(\.title) } == [
        ["Language", "Country", "Notifications"],
        ["About", "Feedback"],
    ])
    #expect(viewModel.sections[0][0].detail == "French")
    #expect(viewModel.sections[0][0].accessibilityIdentifier == "SettingsCell_language")
    #expect(viewModel.sections[1][1].action == .feedback)
}

@MainActor
struct SettingsSnapshotTests {
    @Test func settingsScreen() {
        let view = SettingsModuleFactory.make()
            .preferredColorScheme(.light)

        assertSnapshot(of: view, as: .image(layout: .fixed(width: 390, height: 720)))
    }
}
