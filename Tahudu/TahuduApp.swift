//
//  TahuduApp.swift
//  Tahudu
//

import SwiftUI
#if DEBUG
    import Caching
    import netfox
    import Networking
#endif

@main
struct TahuduApp: App {
    private let appRoot: AppCompositionRoot

    init() {
        #if DEBUG
            if let identifier = ProcessInfo.processInfo.environment["TAHUDU_UI_TEST_STORE"],
               let uuid = UUID(uuidString: identifier) {
                let storeURL = FileManager.default.temporaryDirectory.appendingPathComponent("TahuduUITest-\(uuid.uuidString).sqlite")
                appRoot = AppCompositionRoot(
                    client: UIFlowAPIClient(),
                    cache: CacheManager(strategy: .data(storeURL: storeURL))
                )
            } else {
                NFX.sharedInstance().start()
                appRoot = AppCompositionRoot()
            }
        #else
            appRoot = AppCompositionRoot()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            appRoot.makeRootView()
        }
    }
}
