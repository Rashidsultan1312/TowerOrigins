import SwiftUI

struct QuizView: View {
    @EnvironmentObject private var index: JourneyIndex

    @State private var phase: Phase = .intro
    @State private var session: QuizSession = QuizDeck.makeSession()
    @State private var lastChoice: Int? = nil
    @State private var lastCorrect: Bool = false

    enum Phase {
        case intro, playing, explaining, result
    }

    var body: some View {
        ZStack {
            Pigment.heroGrad.ignoresSafeArea()

            switch phase {
            case .intro:
                introScreen
            case .playing:
                playingScreen
            case .explaining:
                explainScreen
            case .result:
                resultScreen
            }
        }
        .navigationTitle("quiz.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Pigment.navy, for: .navigationBar)
    }

    private var introScreen: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 20)
            ZStack {
                Circle()
                    .fill(Pigment.gold.opacity(0.15))
                    .frame(width: 200, height: 200)
                Image(systemName: "questionmark.bubble.fill")
                    .font(.system(size: 96, weight: .bold))
                    .foregroundStyle(Pigment.gold)
                    .shadow(color: Pigment.gold.opacity(0.5), radius: 14)
            }

            Text("quiz.intro.title")
                .font(.towerHero)
                .foregroundStyle(Pigment.textHi)
                .multilineTextAlignment(.center)

            Text(String(format: NSLocalizedString("quiz.intro.text", comment: ""), session.questions.count))
                .font(.towerLead)
                .foregroundStyle(Pigment.textMid)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            if index.quizBest > 0 {
                Text(String(format: NSLocalizedString("quiz.intro.best", comment: ""), index.quizBest))
                    .font(.towerH3)
                    .foregroundStyle(Pigment.gold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(Pigment.panel)
                    )
                    .overlay(
                        Capsule().stroke(Pigment.gold.opacity(0.5), lineWidth: 1)
                    )
            }

            Spacer()

            Button {
                startQuiz()
            } label: {
                Text("quiz.intro.start")
                    .primaryGoldButton()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .padding(.horizontal, 16)
    }

    private var playingScreen: some View {
        VStack(spacing: 18) {
            progressHeader
            if let q = session.current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(q.prompt)
                            .font(.towerH1)
                            .foregroundStyle(Pigment.textHi)
                            .padding(.horizontal, 4)

                        VStack(spacing: 10) {
                            ForEach(Array(q.options.enumerated()), id: \.offset) { i, opt in
                                optionButton(label: opt, idx: i, question: q)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text(String(format: NSLocalizedString("quiz.progress", comment: ""), session.currentIndex + 1, session.total))
                    .font(.towerCap)
                    .foregroundStyle(Pigment.textMid)
                Spacer()
                Label("\(session.score)", systemImage: "star.fill")
                    .font(.towerCap)
                    .foregroundStyle(Pigment.gold)
            }
            ProgressBar(progress: Double(session.currentIndex) / Double(max(session.total, 1)))
                .frame(height: 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func optionButton(label: String, idx: Int, question: QuizQuestion) -> some View {
        let isAnswered = lastChoice != nil
        let isCorrect = idx == question.answerIndex
        let isPicked = idx == lastChoice

        let bg: Color = {
            if !isAnswered { return Pigment.panel }
            if isCorrect { return Pigment.win.opacity(0.25) }
            if isPicked { return Pigment.loss.opacity(0.25) }
            return Pigment.panel
        }()
        let border: Color = {
            if !isAnswered { return Pigment.stoneDeep.opacity(0.4) }
            if isCorrect { return Pigment.win }
            if isPicked { return Pigment.loss }
            return Pigment.stoneDeep.opacity(0.4)
        }()

        return Button {
            guard lastChoice == nil else { return }
            answer(idx)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(border, lineWidth: 1.5)
                        .frame(width: 28, height: 28)
                    if isAnswered, isCorrect {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(Pigment.win)
                    } else if isAnswered, isPicked {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(Pigment.loss)
                    } else {
                        Text(letter(for: idx))
                            .font(.system(.footnote, design: .rounded, weight: .black))
                            .foregroundStyle(Pigment.textMid)
                    }
                }
                Text(label)
                    .font(.towerBody)
                    .foregroundStyle(Pigment.textHi)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(border, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
    }

    private var explainScreen: some View {
        guard let q = session.current else {
            return AnyView(EmptyView())
        }
        return AnyView(
            QuizExplainView(
                question: q,
                pickedIndex: lastChoice ?? -1,
                wasCorrect: lastCorrect,
                isLast: session.isLast
            ) {
                advance()
            }
        )
    }

    private var resultScreen: some View {
        QuizResultView(
            score: session.score,
            total: session.total,
            isNewBest: session.score == index.quizBest && session.score > 0
        ) {
            startQuiz()
        } onClose: {
            phase = .intro
            session = QuizDeck.makeSession()
            lastChoice = nil
        }
    }

    private func startQuiz() {
        session = QuizDeck.makeSession()
        lastChoice = nil
        withAnimation(.interpolatingSpring(stiffness: 180, damping: 18)) {
            phase = .playing
        }
    }

    private func answer(_ idx: Int) {
        lastChoice = idx
        lastCorrect = session.answer(idx)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.interpolatingSpring(stiffness: 180, damping: 18)) {
                phase = .explaining
            }
        }
    }

    private func advance() {
        if session.isLast {
            session.advance()
            _ = index.recordQuizScore(session.score)
            withAnimation(.interpolatingSpring(stiffness: 180, damping: 18)) {
                phase = .result
            }
        } else {
            session.advance()
            lastChoice = nil
            withAnimation(.interpolatingSpring(stiffness: 180, damping: 18)) {
                phase = .playing
            }
        }
    }

    private func letter(for idx: Int) -> String {
        let letters = ["A", "B", "C", "D", "E"]
        return idx < letters.count ? letters[idx] : "?"
    }
}

struct ProgressBar: View {
    var progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Pigment.panel)
                Capsule()
                    .fill(Pigment.goldGrad)
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
                    .shadow(color: Pigment.gold.opacity(0.5), radius: 6)
            }
        }
    }
}
