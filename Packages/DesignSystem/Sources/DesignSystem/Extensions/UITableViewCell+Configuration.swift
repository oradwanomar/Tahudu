import UIKit

public extension UITableViewCell {
    static func dequeueConfigured(
        from tableView: UITableView,
        reuseIdentifier: String,
        style: CellStyle = .value1,
        title: String,
        detail: String?,
        systemImageName: String,
        accessibilityIdentifier: String
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: style, reuseIdentifier: reuseIdentifier)
        cell.configure(
            title: title,
            detail: detail,
            systemImageName: systemImageName,
            accessibilityIdentifier: accessibilityIdentifier
        )
        return cell
    }

    func configure(
        title: String,
        detail: String?,
        systemImageName: String,
        accessibilityIdentifier: String
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
        backgroundColor = DSUIColor.background
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        imageView?.image = UIImage(systemName: systemImageName)
        textLabel?.text = title
        textLabel?.textColor = DSUIColor.primaryText
        textLabel?.textAlignment = .natural
        detailTextLabel?.text = detail
        detailTextLabel?.textColor = DSUIColor.secondaryText
    }
}
