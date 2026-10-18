import DesignSystem
import UIKit

final class SettingsViewController: UITableViewController {
    private let viewModel: any SettingsViewModelProtocol
    private let cellReuseIdentifier = "SettingsCell"

    init(viewModel: any SettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = DSUIColor.groupedBackground
    }

    override func numberOfSections(in _: UITableView) -> Int {
        viewModel.sections.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.sections[indexPath.section][indexPath.row]
        return UITableViewCell.dequeueConfigured(
            from: tableView,
            reuseIdentifier: cellReuseIdentifier,
            title: model.title,
            detail: model.detail,
            systemImageName: model.symbolName,
            accessibilityIdentifier: model.accessibilityIdentifier
        )
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectRow(indexPath.row, in: indexPath.section)
    }
}
