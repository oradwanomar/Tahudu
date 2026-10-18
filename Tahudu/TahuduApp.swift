//
//  TahuduApp.swift
//  Tahudu
//

import DesignSystem
import SwiftUI
#if DEBUG
    import netfox
#endif

@main
struct TahuduApp: App {
    init() {
        #if DEBUG
            NFX.sharedInstance().start()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            TahuduTabView()
                .accentColor(DSColor.accent)
        }
    }
}
