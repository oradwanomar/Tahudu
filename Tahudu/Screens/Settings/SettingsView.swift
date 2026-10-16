//
//  SettingsView.swift
//  Tahudu
//

import SwiftUI

struct SettingsView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UINavigationController {
        let settingsViewController = SettingsViewController(style: .insetGrouped)
        settingsViewController.title = "My Account"

        let navigatoinController = UINavigationController(rootViewController: settingsViewController)
        navigatoinController.navigationBar.prefersLargeTitles = true
        return navigatoinController
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {
        // Nothing here
    }
}
