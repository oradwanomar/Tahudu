import Foundation

@MainActor
public protocol SettingsViewModelProtocol {
    var sections: [[SettingsCellViewModel]] { get }
    func selectRow(_ row: Int, in section: Int)
}

@MainActor
public final class SettingsViewModel: SettingsViewModelProtocol {
    public let sections: [[SettingsCellViewModel]]
    private let coordinator: any SettingsCoordinatorProtocol

    public init(
        languageCode: String = Bundle.main.preferredLocalizations.first ?? Locale.current.languageCode ?? "en",
        locale: Locale = .current,
        coordinator: any SettingsCoordinatorProtocol
    ) {
        self.coordinator = coordinator
        sections = [
            [
                SettingsCellViewModel(
                    title: "Language",
                    symbolName: "textformat",
                    detail: locale.localizedString(forLanguageCode: languageCode),
                    action: .language
                ),
                SettingsCellViewModel(
                    title: "Country",
                    symbolName: "globe",
                    detail: "United Arab Emirates",
                    action: .country
                ),
                SettingsCellViewModel(
                    title: "Notifications",
                    symbolName: "app.badge",
                    action: .notifications
                ),
            ],
            [
                SettingsCellViewModel(title: "About", symbolName: "info.circle", action: .about),
                SettingsCellViewModel(title: "Feedback", symbolName: "text.bubble", action: .feedback),
            ],
        ]
    }

    public func selectRow(_ row: Int, in section: Int) {
        guard sections.indices.contains(section), sections[section].indices.contains(row) else { return }
        coordinator.navigate(to: sections[section][row].action)
    }
}
