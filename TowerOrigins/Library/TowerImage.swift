import SwiftUI

struct TowerImage: View {
    let tower: Tower
    var mode: Mode = .thumb

    enum Mode {
        case hero, thumb, square
    }

    var body: some View {
        ZStack {
            backdrop
            if let ui = UIImage(named: tower.imageName) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .clipped()
    }

    @ViewBuilder
    private var backdrop: some View {
        switch mode {
        case .hero:
            LinearGradient(
                colors: [Pigment.skyDeep, Pigment.navy],
                startPoint: .top,
                endPoint: .bottom
            )
        case .thumb, .square:
            LinearGradient(
                colors: [Pigment.panelHi, Pigment.panel],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    @ViewBuilder
    private var placeholder: some View {
        VStack(spacing: 8) {
            Image(systemName: tower.kind.symbol)
                .font(.system(size: mode == .hero ? 64 : 36, weight: .bold))
                .foregroundStyle(Pigment.gold.opacity(0.9))
                .shadow(color: Pigment.gold.opacity(0.4), radius: 8)
            if mode == .hero {
                Text(tower.centuryLabel)
                    .font(.towerCap)
                    .foregroundStyle(Pigment.textMid)
            }
        }
        .padding()
    }
}

struct KindBadge: View {
    let kind: TowerKind

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: kind.symbol)
            Text(LocalizedStringKey(kind.localizationKey))
        }
        .font(.towerCap)
        .foregroundStyle(Pigment.navy)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Pigment.goldGrad)
        )
    }
}

struct EraBadge: View {
    let era: Era

    var body: some View {
        Text(LocalizedStringKey(era.localizationKey))
            .font(.towerCap)
            .foregroundStyle(Pigment.textHi)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Pigment.panel)
            )
            .overlay(
                Capsule().stroke(Pigment.stone.opacity(0.4), lineWidth: 1)
            )
    }
}
