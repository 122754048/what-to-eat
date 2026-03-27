import SwiftUI

@main
struct WhatToEatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// 5-Tab 主导航界面
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
            ExploreView()
                .tabItem {
                    Label("发现", systemImage: "magnifyingglass")
                }
            CuisineSelectionPage()
                .tabItem {
                    Label("菜系", systemImage: "fork.knife")
                }
            FavoritesPage()
                .tabItem {
                    Label("收藏", systemImage: "heart.fill")
                }
            MyProfilePage()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
        .tint(Color(hex: "#8B9A6D")) // 鼠尾草绿主题色
    }
}
