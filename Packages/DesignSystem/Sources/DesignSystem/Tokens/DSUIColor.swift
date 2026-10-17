import UIKit

public enum DSUIColor {
    public static let accent = UIColor(named: "Accent", in: .module, compatibleWith: nil) ?? .systemBlue
    public static let brand = UIColor(named: "Brand", in: .module, compatibleWith: nil) ?? .systemRed
    public static let whatsApp = UIColor(named: "WhatsApp", in: .module, compatibleWith: nil) ?? .systemGreen
    public static let background = UIColor.systemBackground
    public static let groupedBackground = UIColor.systemGroupedBackground
    public static let primaryText = UIColor.label
    public static let secondaryText = UIColor.secondaryLabel
}
