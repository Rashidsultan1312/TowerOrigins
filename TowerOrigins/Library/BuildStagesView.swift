import SwiftUI

struct BuildStagesView: View {
    let tower: Tower
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ArchiveCarousel(prefix: "\(tower.imageName)_stages")

                    Text(tower.name)
                        .font(.towerH2)
                        .foregroundStyle(Pigment.textHi)

                    ForEach(tower.buildStages.sorted(by: { $0.order < $1.order }), id: \.order) { stage in
                        StageRow(stage: stage)
                    }
                }
                .padding(20)
            }
            .background(Pigment.heroGrad.ignoresSafeArea())
            .navigationTitle("sheet.stages.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Pigment.navy, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sheet.close") { dismiss() }
                        .foregroundStyle(Pigment.gold)
                }
            }
        }
    }
}

private struct StageRow: View {
    let stage: BuildStage

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Pigment.goldGrad)
                    .frame(width: 38, height: 38)
                Text("\(stage.order)")
                    .font(.system(.headline, design: .rounded, weight: .black))
                    .foregroundStyle(Pigment.navy)
            }
            .shadow(color: Pigment.gold.opacity(0.4), radius: 6)

            VStack(alignment: .leading, spacing: 6) {
                Text(stage.title)
                    .font(.towerH3)
                    .foregroundStyle(Pigment.textHi)
                Text(stage.description)
                    .font(.towerBody)
                    .foregroundStyle(Pigment.textMid)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Pigment.panelGrad)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Pigment.gold.opacity(0.18), lineWidth: 1)
        )
    }
}
