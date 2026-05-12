import SwiftUI

struct TowerDetailView: View {
    let tower: Tower
    @EnvironmentObject private var index: JourneyIndex

    @State private var showStages: Bool = false
    @State private var showInterior: Bool = false
    @State private var showFacts: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                heroBlock

                metaRow

                Text(tower.brief)
                    .font(.towerLead)
                    .foregroundStyle(Pigment.textHi)
                    .padding(.horizontal, 4)

                didYouKnowBlock
                    .padding(.top, 4)

                actionsRow

                favouriteButton
            }
            .padding(.horizontal, 18)
            .padding(.top, 4)
            .padding(.bottom, 36)
        }
        .background(Pigment.heroGrad.ignoresSafeArea())
        .navigationTitle(tower.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Pigment.navy, for: .navigationBar)
        .onAppear {
            index.markViewed(tower.id)
        }
        .sheet(isPresented: $showStages) {
            BuildStagesView(tower: tower)
        }
        .sheet(isPresented: $showInterior) {
            InteriorView(tower: tower)
        }
        .sheet(isPresented: $showFacts) {
            HistoricFactsView(tower: tower)
        }
    }

    private var heroBlock: some View {
        TowerImage(tower: tower, mode: .hero)
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Pigment.gold.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 12, y: 8)
    }

    private var metaRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                KindBadge(kind: tower.kind)
                EraBadge(era: tower.era)
                Spacer()
                Text(tower.centuryLabel)
                    .font(.towerCap)
                    .foregroundStyle(Pigment.textMid)
            }
            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                Text(tower.location)
            }
            .font(.towerCap)
            .foregroundStyle(Pigment.textMid)
        }
    }

    private var didYouKnowBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("detail.didYouKnow", systemImage: "lightbulb.fill")
                .font(.towerH3)
                .foregroundStyle(Pigment.gold)
            Text(tower.fact)
                .font(.towerBody)
                .foregroundStyle(Pigment.textHi)
        }
        .stonePanel(elevated: true)
    }

    private var actionsRow: some View {
        HStack(spacing: 10) {
            actionTile(
                titleKey: "detail.section.stages",
                symbol: "square.stack.3d.up.fill",
                tone: Pigment.sky
            ) { showStages = true }

            actionTile(
                titleKey: "detail.section.interior",
                symbol: "house.fill",
                tone: Pigment.beige
            ) { showInterior = true }

            actionTile(
                titleKey: "detail.section.facts",
                symbol: "scroll.fill",
                tone: Pigment.gold
            ) { showFacts = true }
        }
    }

    private func actionTile(titleKey: String, symbol: String, tone: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(tone)
                Text(LocalizedStringKey(titleKey))
                    .font(.towerCap)
                    .foregroundStyle(Pigment.textHi)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Pigment.panelGrad)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(tone.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var favouriteButton: some View {
        let isFav = index.isFavorite(tower.id)
        return Button {
            withAnimation(.interpolatingSpring(stiffness: 220, damping: 16)) {
                index.toggleFavorite(tower.id)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isFav ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .bold))
                Text(isFav ? "detail.favorite.remove" : "detail.favorite.add")
            }
            .font(.system(.headline, design: .rounded, weight: .bold))
            .foregroundStyle(isFav ? Pigment.gold : Pigment.textHi)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isFav ? Pigment.panel : Pigment.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isFav ? Pigment.gold : Pigment.stone.opacity(0.4), lineWidth: 1.5)
            )
            .shadow(color: isFav ? Pigment.gold.opacity(0.4) : .clear, radius: 14, y: 4)
        }
    }
}
