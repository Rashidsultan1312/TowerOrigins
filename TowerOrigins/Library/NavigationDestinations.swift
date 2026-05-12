import SwiftUI

struct TowerNavigation: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavRoute.self) { route in
                switch route {
                case .detail(let id):
                    TowerDetailRoute(id: id)
                case .explore:
                    ExploreView()
                case .exploreFiltered:
                    ExploreView()
                case .quiz:
                    QuizView()
                }
            }
    }
}

private struct TowerDetailRoute: View {
    let id: String
    @EnvironmentObject private var library: TowerLibrary

    var body: some View {
        if let tower = library.tower(byID: id) {
            TowerDetailView(tower: tower)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "questionmark.diamond")
                    .font(.system(size: 48))
                    .foregroundStyle(Pigment.textMid)
                Text("detail.missing")
                    .font(.towerH2)
                    .foregroundStyle(Pigment.textHi)
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Pigment.heroGrad.ignoresSafeArea())
        }
    }
}

extension View {
    func withTowerNavigation() -> some View { modifier(TowerNavigation()) }
}
