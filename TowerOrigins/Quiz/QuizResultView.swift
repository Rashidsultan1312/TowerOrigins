import SwiftUI

struct QuizResultView: View {
    let score: Int
    let total: Int
    let isNewBest: Bool
    let onRetry: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 16)

            Text("quiz.result.title")
                .font(.towerH2)
                .foregroundStyle(Pigment.textMid)

            Text("\(score)")
                .font(.towerScore)
                .goldGlow(radius: 24)

            Text(String(format: NSLocalizedString("quiz.result.score", comment: ""), score, total))
                .font(.towerH2)
                .foregroundStyle(Pigment.textHi)

            if isNewBest {
                Label("quiz.result.new_best", systemImage: "crown.fill")
                    .font(.towerH3)
                    .foregroundStyle(Pigment.gold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Pigment.gold.opacity(0.18)))
                    .overlay(Capsule().stroke(Pigment.gold, lineWidth: 1))
            }

            badgeRow

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onRetry()
                } label: {
                    Text("quiz.result.retry")
                        .primaryGoldButton()
                }

                Button {
                    onClose()
                } label: {
                    Text("quiz.result.back")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(Pigment.textMid)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Pigment.stoneDeep.opacity(0.6), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }

    private var badgeRow: some View {
        HStack(spacing: 16) {
            badge(symbol: "checkmark.seal.fill", value: "\(score)", colour: Pigment.win)
            badge(symbol: "xmark.seal.fill", value: "\(total - score)", colour: Pigment.loss)
            badge(symbol: "percent", value: percent, colour: Pigment.gold)
        }
        .padding(.horizontal, 24)
    }

    private var percent: String {
        guard total > 0 else { return "0" }
        let v = Int(round(Double(score) / Double(total) * 100))
        return "\(v)"
    }

    private func badge(symbol: String, value: String, colour: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(colour)
            Text(value)
                .font(.towerCounter)
                .foregroundStyle(Pigment.textHi)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Pigment.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(colour.opacity(0.35), lineWidth: 1)
        )
    }
}
