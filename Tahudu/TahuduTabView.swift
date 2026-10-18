//
//  TahuduTabView.swift
//  Tahudu
//

import AnalyticsInterface
import DesignSystem
import SwiftUI

struct TahuduTabView<Content: View>: View {
    @State private var selectedTab: Tabs = .search
    private let analytics: any AnalyticsEventTracking
    private let content: (Tabs) -> Content

    init(
        analytics: any AnalyticsEventTracking,
        @ViewBuilder content: @escaping (Tabs) -> Content
    ) {
        self.analytics = analytics
        self.content = content
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tabs.allCases, id: \.self) { tab in
                content(tab)
                    .tag(tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.symbol(isSelected: selectedTab == tab))
                    }
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

    var title: String {
        switch self {
        case .search:
            return "Search"
        case .settings:
            return "My Account"
        }
    }

    func symbol(isSelected: Bool) -> String {
        switch self {
        case .search:
            return "magnifyingglass"
        case .settings:
            return isSelected ? "person.fill" : "person"
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
        AppCompositionRoot().makeRootView()
    }
}
