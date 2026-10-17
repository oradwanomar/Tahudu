import Foundation

public protocol SettingsViewModelProtocol {
    var sections: [[SettingsCellViewModel]] { get }
}

public final class SettingsViewModel: SettingsViewModelProtocol {
    public let sections: [[SettingsCellViewModel]]

    public init(
        languageCode: String = Bundle.main.preferredLocalizations.first ?? Locale.current.languageCode ?? "en",
        locale: Locale = .current
    ) {
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
}
