import SwiftUI

@main
struct JourneyAppRoot: App {
    @StateObject private var library = TowerLibrary()
    @StateObject private var index = JourneyIndex()

    init() {
        GateProbe.bootstrap(host: AppConfig.relayHost,
                            key: AppConfig.relayKey,
                            timeout: AppConfig.relayTimeout,
                            targets: AppConfig.relayTargets)
        Self.dressNavigation()
        Self.dressTabBar()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(library)
                .environmentObject(index)
                .preferredColorScheme(.dark)
        }
    }

    private static func dressNavigation() {
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(Pigment.navy)
        nav.titleTextAttributes = [.foregroundColor: UIColor(Pigment.textHi)]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor(Pigment.textHi)]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
    }

    private static func dressTabBar() {
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(Pigment.surface)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }
}
