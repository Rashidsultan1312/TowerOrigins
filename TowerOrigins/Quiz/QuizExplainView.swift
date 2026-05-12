import SwiftUI

struct QuizExplainView: View {
    let question: QuizQuestion
    let pickedIndex: Int
    let wasCorrect: Bool
    let isLast: Bool
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 16)

            ZStack {
                Circle()
                    .fill((wasCorrect ? Pigment.win : Pigment.loss).opacity(0.15))
                    .frame(width: 160, height: 160)
                Image(systemName: wasCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .font(.system(size: 84, weight: .black))
                    .foregroundStyle(wasCorrect ? Pigment.win : Pigment.loss)
                    .shadow(color: (wasCorrect ? Pigment.win : Pigment.loss).opacity(0.45), radius: 14)
            }

            Text(LocalizedStringKey(wasCorrect ? "quiz.correct" : "quiz.incorrect"))
                .font(.towerHero)
                .foregroundStyle(wasCorrect ? Pigment.win : Pigment.loss)

            VStack(alignment: .leading, spacing: 10) {
                Text(question.prompt)
                    .font(.towerH3)
                    .foregroundStyle(Pigment.textHi)

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Pigment.win)
                    Text(question.options[question.answerIndex])
                        .font(.towerBody)
                        .foregroundStyle(Pigment.textHi)
                }

                Text(question.explanation)
                    .font(.towerBody)
                    .foregroundStyle(Pigment.textMid)
                    .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Pigment.panelGrad)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Pigment.gold.opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal, 16)

            Spacer()

            Button {
                onNext()
            } label: {
                Text(LocalizedStringKey(isLast ? "quiz.result.title" : "quiz.next"))
                    .primaryGoldButton()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }
}
