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
            DiscoverView()
                .tabItem {
                    Label("发现", systemImage: "magnifyingglass")
                }
            CuisineView()
                .tabItem {
                    Label("菜系", systemImage: "fork.knife")
                }
            FavoritesView()
                .tabItem {
                    Label("收藏", systemImage: "heart.fill")
                }
            MyProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
        .tint(Color(hex: "#8B9A6D")) // 鼠尾草绿主题色
    }
}

// 占位页面（待ui-designer实现完整SwiftUI）
struct DiscoverView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#8B9A6D"))
            Text("发现页")
                .font(.title)
            Text("待ui-designer实现")
                .foregroundColor(.secondary)
        }
    }
}

struct CuisineView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#8B9A6D"))
            Text("菜系列表")
                .font(.title)
            Text("待ui-designer实现")
                .foregroundColor(.secondary)
        }
    }
}

struct FavoritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#8B9A6D"))
            Text("收藏页")
                .font(.title)
            Text("待ui-designer实现")
                .foregroundColor(.secondary)
        }
    }
}

struct MyProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#8B9A6D"))
            Text("我的页面")
                .font(.title)
            Text("待ui-designer实现")
                .foregroundColor(.secondary)
        }
    }
}
