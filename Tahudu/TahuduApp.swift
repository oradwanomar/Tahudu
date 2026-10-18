//
//  TahuduApp.swift
//  Tahudu
//

import SwiftUI
#if DEBUG
    import netfox
#endif

@main
struct TahuduApp: App {
    private let appRoot: AppCompositionRoot

    init() {
        #if DEBUG
            NFX.sharedInstance().start()
        #endif
        appRoot = AppCompositionRoot()
    }

    var body: some Scene {
        WindowGroup {
            appRoot.makeRootView()
        }
    }
}
