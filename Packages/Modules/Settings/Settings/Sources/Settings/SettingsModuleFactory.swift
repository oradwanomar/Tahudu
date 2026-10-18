import DesignSystem
import SwiftUI

@MainActor
public enum SettingsModuleFactory {
    public static func make() -> some View {
        SettingsView(viewModel: SettingsViewModel(coordinator: SettingsCoordinator()))
            .background(DSColor.groupedBackground.ignoresSafeArea())
    }
}
