import SwiftUI

struct HistoricFactsView: View {
    let tower: Tower
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(tower.name)
                        .font(.towerH2)
                        .foregroundStyle(Pigment.textHi)

                    ForEach(Array(tower.historicFacts.enumerated()), id: \.offset) { _, fact in
                        FactRow(fact: fact)
                    }
                }
                .padding(20)
            }
            .background(Pigment.heroGrad.ignoresSafeArea())
            .navigationTitle("sheet.facts.title")
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

private struct FactRow: View {
    let fact: HistoricFact

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 2) {
                if let year = fact.year {
                    Text(year)
                        .font(.system(.subheadline, design: .rounded, weight: .black))
                        .foregroundStyle(Pigment.gold)
                        .multilineTextAlignment(.center)
                } else {
                    Image(systemName: "scroll.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Pigment.gold)
                }
            }
            .frame(width: 64)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Pigment.gold.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Pigment.gold.opacity(0.45), lineWidth: 1)
            )

            Text(fact.description)
                .font(.towerBody)
                .foregroundStyle(Pigment.textHi)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
        .padding(14)
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
