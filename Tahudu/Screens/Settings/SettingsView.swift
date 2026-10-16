//
//  SettingsView.swift
//  Tahudu
//

import DesignSystem
import SwiftUI

struct SettingsView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UINavigationController {
        let settingsViewController = SettingsViewController(style: .insetGrouped)
        settingsViewController.title = "My Account"

        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.view.tintColor = DSUIColor.accent
        return navigationController
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {
        // Nothing here
    }
}
