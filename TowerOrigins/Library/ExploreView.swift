import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var library: TowerLibrary
    @State private var filterOpen: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(library.filtered) { tower in
                    NavigationLink(value: NavRoute.detail(tower.id)) {
                        gridTile(tower)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .padding(.bottom, 36)

            if library.filtered.isEmpty {
                emptyState
            }
        }
        .background(Pigment.heroGrad.ignoresSafeArea())
        .searchable(text: $library.searchQuery, prompt: Text("explore.search"))
        .navigationTitle("explore.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Pigment.navy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    filterOpen.toggle()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(Pigment.gold)
                        if library.activeFilterCount > 0 {
                            Circle()
                                .fill(Pigment.gold)
                                .frame(width: 8, height: 8)
                                .offset(x: 6, y: -4)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $filterOpen) {
            FilterSheet().environmentObject(library)
        }
        .withTowerNavigation()
    }

    private func gridTile(_ tower: Tower) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TowerImage(tower: tower, mode: .square)
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(tower.name)
                .font(.towerH3)
                .foregroundStyle(Pigment.textHi)
                .lineLimit(2)

            HStack(spacing: 6) {
                Image(systemName: tower.kind.symbol)
                Text(LocalizedStringKey(tower.kind.localizationKey))
                Spacer()
                Text(tower.centuryLabel)
            }
            .font(.towerCap)
            .foregroundStyle(Pigment.textMid)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Pigment.panelGrad)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Pigment.gold.opacity(0.12), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Pigment.textMid)
            Text("explore.empty")
                .font(.towerLead)
                .foregroundStyle(Pigment.textMid)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, 24)
    }
}

struct FilterSheet: View {
    @EnvironmentObject private var library: TowerLibrary
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    sectionHeader("explore.filter.kind")
                    chipGrid(items: TowerKind.allCases,
                             isSelected: { library.kindFilters.contains($0) },
                             label: { LocalizedStringKey($0.localizationKey) },
                             symbol: { $0.symbol },
                             toggle: { library.toggleKind($0) })

                    sectionHeader("explore.filter.era")
                    chipGrid(items: Era.allCases,
                             isSelected: { library.eraFilters.contains($0) },
                             label: { LocalizedStringKey($0.localizationKey) },
                             symbol: { _ in "hourglass" },
                             toggle: { library.toggleEra($0) })
                }
                .padding(20)
            }
            .background(Pigment.heroGrad.ignoresSafeArea())
            .navigationTitle("explore.filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Pigment.navy, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("explore.filter.clear") {
                        library.clearFilters()
                    }
                    .foregroundStyle(Pigment.textMid)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("explore.filter.apply") {
                        dismiss()
                    }
                    .foregroundStyle(Pigment.gold)
                    .fontWeight(.bold)
                }
            }
        }
    }

    private func sectionHeader(_ key: String) -> some View {
        Text(LocalizedStringKey(key))
            .font(.towerH3)
            .foregroundStyle(Pigment.textHi)
    }

    private func chipGrid<Item: Hashable & Identifiable>(
        items: [Item],
        isSelected: @escaping (Item) -> Bool,
        label: @escaping (Item) -> LocalizedStringKey,
        symbol: @escaping (Item) -> String,
        toggle: @escaping (Item) -> Void
    ) -> some View {
        let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { it in
                let on = isSelected(it)
                Button {
                    withAnimation(.interpolatingSpring(stiffness: 220, damping: 18)) {
                        toggle(it)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: symbol(it))
                        Text(label(it))
                            .lineLimit(1)
                    }
                    .font(.towerCap)
                    .foregroundStyle(on ? Pigment.navy : Pigment.textHi)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule().fill(on ? Pigment.goldGrad : LinearGradient(colors: [Pigment.panel, Pigment.panel], startPoint: .top, endPoint: .bottom))
                    )
                    .overlay(
                        Capsule().stroke(on ? Pigment.goldDeep : Pigment.stoneDeep.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
