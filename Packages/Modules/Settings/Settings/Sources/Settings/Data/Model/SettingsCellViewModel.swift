public enum SettingsAction: String {
    case language
    case country
    case notifications
    case about
    case feedback
}

public struct SettingsCellViewModel {
    public let title: String
    public let symbolName: String
    public let detail: String?
    public let action: SettingsAction

    public var accessibilityIdentifier: String {
        "SettingsCell_\(action.rawValue)"
    }

    public init(title: String, symbolName: String, detail: String? = nil, action: SettingsAction) {
        self.title = title
        self.symbolName = symbolName
        self.detail = detail
        self.action = action
    }
}
