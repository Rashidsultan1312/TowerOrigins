import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var library: TowerLibrary
    @EnvironmentObject private var index: JourneyIndex

    var body: some View {
        Group {
            if savedTowers.isEmpty {
                emptyState
            } else {
                listScreen
            }
        }
        .background(Pigment.heroGrad.ignoresSafeArea())
        .navigationTitle("favorites.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Pigment.navy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .withTowerNavigation()
    }

    private var savedTowers: [Tower] {
        library.towers
            .filter { index.favoriteIDs.contains($0.id) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var listScreen: some View {
        List {
            ForEach(savedTowers) { tower in
                NavigationLink(value: NavRoute.detail(tower.id)) {
                    row(tower)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .onDelete { offsets in
                for off in offsets {
                    let tower = savedTowers[off]
                    index.toggleFavorite(tower.id)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(_ tower: Tower) -> some View {
        HStack(spacing: 12) {
            TowerImage(tower: tower, mode: .square)
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(tower.name)
                    .font(.towerH3)
                    .foregroundStyle(Pigment.textHi)
                HStack(spacing: 6) {
                    Image(systemName: tower.kind.symbol)
                    Text(LocalizedStringKey(tower.kind.localizationKey))
                    Text("·")
                    Text(tower.location)
                }
                .font(.towerCap)
                .foregroundStyle(Pigment.textMid)
                .lineLimit(1)
            }
            Spacer()
            Image(systemName: "heart.fill")
                .foregroundStyle(Pigment.gold)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Pigment.panelGrad)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Pigment.gold.opacity(0.18), lineWidth: 1)
        )
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Pigment.gold.opacity(0.12))
                    .frame(width: 140, height: 140)
                Image(systemName: "heart.slash")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(Pigment.gold.opacity(0.85))
            }
            Text("favorites.empty.title")
                .font(.towerH2)
                .foregroundStyle(Pigment.textHi)
            Text("favorites.empty.text")
                .font(.towerLead)
                .foregroundStyle(Pigment.textMid)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
            Spacer()
            Spacer()
        }
    }
}
