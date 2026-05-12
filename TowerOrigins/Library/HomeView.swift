import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var library: TowerLibrary
    @EnvironmentObject private var index: JourneyIndex

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                heroHeader
                if let featured = library.featured {
                    featuredBlock(featured)
                }
                quickSectionsGrid
                popularStrip
                statsRow
            }
            .padding(.horizontal, 18)
            .padding(.top, 4)
            .padding(.bottom, 36)
        }
        .background(Pigment.heroGrad.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .withTowerNavigation()
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("home.title")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(Pigment.textHi)
            Text("home.subtitle")
                .font(.towerLead)
                .foregroundStyle(Pigment.textMid)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private func featuredBlock(_ tower: Tower) -> some View {
        NavigationLink(value: NavRoute.detail(tower.id)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("home.featured", systemImage: "star.fill")
                        .font(.towerCap)
                        .foregroundStyle(Pigment.gold)
                    Spacer()
                    Text(tower.centuryLabel)
                        .font(.towerCap)
                        .foregroundStyle(Pigment.textMid)
                }

                ZStack(alignment: .bottomLeading) {
                    TowerImage(tower: tower, mode: .hero)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    LinearGradient(
                        colors: [.clear, Pigment.navy.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(tower.name)
                            .font(.towerH1)
                            .foregroundStyle(Pigment.textHi)
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                            Text(tower.location)
                        }
                        .font(.towerCap)
                        .foregroundStyle(Pigment.textMid)
                    }
                    .padding(14)
                }

                Text(tower.brief)
                    .font(.towerBody)
                    .foregroundStyle(Pigment.textMid)
                    .lineLimit(3)

                HStack {
                    KindBadge(kind: tower.kind)
                    Spacer()
                    Text("home.featured.cta")
                        .font(.towerH3)
                        .foregroundStyle(Pigment.gold)
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundStyle(Pigment.gold)
                }
            }
            .stonePanel(elevated: true)
        }
        .buttonStyle(.plain)
    }

    private var quickSectionsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("home.sections")
                .font(.towerH2)
                .foregroundStyle(Pigment.textHi)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                quickTile(symbol: "square.stack.3d.up.fill",
                          tone: Pigment.sky,
                          titleKey: "home.section.stages",
                          target: NavRoute.exploreFiltered)
                quickTile(symbol: "house.fill",
                          tone: Pigment.beige,
                          titleKey: "home.section.interior",
                          target: NavRoute.exploreFiltered)
                quickTile(symbol: "scroll.fill",
                          tone: Pigment.gold,
                          titleKey: "home.section.facts",
                          target: NavRoute.exploreFiltered)
                quickTile(symbol: "questionmark.bubble.fill",
                          tone: Pigment.win,
                          titleKey: "home.section.quiz",
                          target: NavRoute.quiz)
            }
        }
    }

    private func quickTile(symbol: String, tone: Color, titleKey: String, target: NavRoute) -> some View {
        NavigationLink(value: target) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle().fill(tone.opacity(0.15)).frame(width: 46, height: 46)
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(tone)
                }
                Text(LocalizedStringKey(titleKey))
                    .font(.towerH3)
                    .foregroundStyle(Pigment.textHi)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Pigment.panelGrad)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(tone.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var popularStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("home.popular")
                    .font(.towerH2)
                    .foregroundStyle(Pigment.textHi)
                Spacer()
                NavigationLink(value: NavRoute.explore) {
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(Pigment.gold)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(library.popular) { tower in
                        NavigationLink(value: NavRoute.detail(tower.id)) {
                            popularChip(tower)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func popularChip(_ tower: Tower) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TowerImage(tower: tower, mode: .thumb)
                .frame(width: 160, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(tower.name)
                .font(.towerH3)
                .foregroundStyle(Pigment.textHi)
                .lineLimit(2)
                .frame(width: 160, alignment: .leading)

            HStack(spacing: 4) {
                Image(systemName: tower.kind.symbol)
                Text(LocalizedStringKey(tower.kind.localizationKey))
            }
            .font(.towerCap)
            .foregroundStyle(Pigment.textMid)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            statBox(value: "\(library.towers.count)", labelKey: "home.stat.towers")
            statBox(value: "\(index.viewedIDs.count)", labelKey: "home.stat.viewed", glow: true)
            statBox(value: "\(index.favoriteIDs.count)", labelKey: "home.stat.favorites")
        }
    }

    private func statBox(value: String, labelKey: String, glow: Bool = false) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.towerCounter)
                .modifier(GlowIf(active: glow))
                .foregroundStyle(glow ? Pigment.gold : Pigment.textHi)
            Text(LocalizedStringKey(labelKey))
                .font(.towerCap)
                .foregroundStyle(Pigment.textMid)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Pigment.panel.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(glow ? Pigment.gold.opacity(0.5) : Pigment.stoneDeep.opacity(0.3), lineWidth: 1)
        )
    }
}

struct GlowIf: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View {
        if active {
            content
                .shadow(color: Pigment.gold.opacity(0.55), radius: 10)
        } else {
            content
        }
    }
}

enum NavRoute: Hashable {
    case detail(String)
    case explore
    case exploreFiltered
    case quiz
}
