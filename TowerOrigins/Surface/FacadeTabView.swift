import SwiftUI

struct FacadeTabView: View {
    @State private var selection: Tab

    init() {
        let raw = UserDefaults.standard.string(forKey: "lib::dev.tab") ?? "home"
        _selection = State(initialValue: Tab(token: raw))
    }

    enum Tab: Hashable {
        case home, explore, quiz, favorites, info

        init(token: String) {
            switch token.lowercased() {
            case "explore":   self = .explore
            case "quiz":      self = .quiz
            case "favorites": self = .favorites
            case "info":      self = .info
            default:          self = .home
            }
        }
    }

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack { HomeView() }
                .tabItem { Label("tab.home", systemImage: "sparkles") }
                .tag(Tab.home)

            NavigationStack { ExploreView() }
                .tabItem { Label("tab.explore", systemImage: "square.grid.2x2.fill") }
                .tag(Tab.explore)

            NavigationStack { QuizView() }
                .tabItem { Label("tab.quiz", systemImage: "questionmark.circle.fill") }
                .tag(Tab.quiz)

            NavigationStack { FavoritesView() }
                .tabItem { Label("tab.favorites", systemImage: "heart.fill") }
                .tag(Tab.favorites)

            NavigationStack { InfoView() }
                .tabItem { Label("tab.info", systemImage: "info.circle.fill") }
                .tag(Tab.info)
        }
        .tint(Pigment.gold)
    }
}
