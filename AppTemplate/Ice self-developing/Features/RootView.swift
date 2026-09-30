import SwiftUI

struct RootView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        Group {
            if store.profile?.onboardingCompleted == true {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

struct MainTabView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        @Bindable var store = store
        TabView(selection: $store.selectedTab) {
            HelmView()
                .tag(AppTab.helm)
                .tabItem { Label("Helm", systemImage: "helm") }
            CourseView()
                .tag(AppTab.course)
                .tabItem { Label("My Course", systemImage: "light.beacon.max") }
            JournalView()
                .tag(AppTab.journal)
                .tabItem { Label("Journal", systemImage: "book.closed") }
            StatisticsView()
                .tag(AppTab.statistics)
                .tabItem { Label("Statistics", systemImage: "chart.bar") }
            ProfileView()
                .tag(AppTab.profile)
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .toolbarBackground(Theme.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
