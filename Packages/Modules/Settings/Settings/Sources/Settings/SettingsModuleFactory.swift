import DesignSystem
import SwiftUI

@MainActor
public enum SettingsModuleFactory {
    public static func make() -> some View {
        make(coordinator: SettingsCoordinator())
    }

    public static func make(coordinator: any SettingsCoordinatorProtocol) -> some View {
        SettingsView(viewModel: SettingsViewModel(coordinator: coordinator))
            .background(DSColor.groupedBackground.ignoresSafeArea())
    }
}
