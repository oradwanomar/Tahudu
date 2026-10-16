//
//  TahuduApp.swift
//  Tahudu
//

import DesignSystem
import SwiftUI

@main
struct TahuduApp: App {
    var body: some Scene {
        WindowGroup {
            TahuduTabView()
                .accentColor(DSColor.accent)
        }
    }
}
