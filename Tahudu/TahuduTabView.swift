//
//  TahuduTabView.swift
//  Tahudu
//

import Analytics
import AnalyticsInterface
import SwiftUI

struct TahuduTabView: View {
    @State private var selectedTab = Tabs.search.rawValue
    private let analytics: any AnalyticsEventTracking

    init(analytics: any AnalyticsEventTracking = AnalyticsEventTracker()) {
        self.analytics = analytics
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            SearchView()
                .tag(Tabs.search.rawValue)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            SettingsView()
                .tag(Tabs.settings.rawValue)
                .tabItem {
                    Label("My Account", systemImage: selectedTab == Tabs.settings.rawValue ? "person.fill" : "person")
                }
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            trackSelectedTab()
        }
        .onChange(of: selectedTab) { _ in
            trackSelectedTab()
        }
    }

    private func trackSelectedTab() {
        guard let tab = Tabs(rawValue: selectedTab) else { return }
        analytics.trackEvent(
            AnalyticsEvent(name: "tab_viewed", parameters: ["tab": tab.analyticsName])
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
