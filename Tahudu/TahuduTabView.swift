//
//  TahuduTabView.swift
//  Tahudu
//

import Analytics
import AnalyticsInterface
import Caching
import DesignSystem
import Networking
import Search
import Settings
import SwiftUI

struct TahuduTabView: View {
    @State private var selectedTab: Tabs = .search
    private let analytics: any AnalyticsEventTracking

    init(
        analytics: any AnalyticsEventTracking = AnalyticsEventTracker()
    ) {
        self.analytics = analytics
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            SearchModuleFactory.make(analytics: analytics)
                .tag(Tabs.search)
                .tabItem {
                    Label("Search",
                          systemImage: "magnifyingglass")
                }

            SettingsModuleFactory.make()
                .tag(Tabs.settings)
                .tabItem {
                    Label("My Account",
                          systemImage: selectedTab == .settings ? "person.fill" : "person")
                }
        }
        .accentColor(DSColor.brand)
        .onAppear {
            trackSelectedTab()
        }
        .onChange(of: selectedTab) { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil,
                                            from: nil,
                                            for: nil)
            trackSelectedTab()
        }
    }

    private func trackSelectedTab() {
        analytics.trackEvent(
            AnalyticsEvent(name: "tab_viewed",
                           parameters: ["tab": selectedTab.analyticsName])
        )
    }
}

enum Tabs: Int, CaseIterable {
    case search = 0
    case settings

    var name: String {
        switch self {
        case .search:
            return "Search"
        case .settings:
            return "Settings"
        }
    }

    var analyticsName: String {
        switch self {
        case .search:
            return "search"
        case .settings:
            return "settings"
        }
    }
}

struct TahuduTabView_Previews: PreviewProvider {
    static var previews: some View {
        TahuduTabView()
    }
}
