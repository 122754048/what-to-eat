import SwiftUI

@main
struct WhatToEatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// 3-Tab 主导航界面
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
            DiscoverView()
                .tabItem {
                    Label("发现", systemImage: "safari.fill")
                }
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
        .tint(Design.Colors.primary)
    }
}
