import SwiftUI

@main
struct WhatToEatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Create a simple ContentView to host the main views for now
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "safari.fill")
                }
            HealthView()
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
        }
    }
}
