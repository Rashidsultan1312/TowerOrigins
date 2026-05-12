import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var index: JourneyIndex
    @State private var pageIdx: Int = 0

    private let slides: [Slide] = [
        Slide(
            symbol: "building.columns.fill",
            tone: Pigment.gold,
            titleKey: "onboarding.1.title",
            textKey: "onboarding.1.text"
        ),
        Slide(
            symbol: "wrench.and.screwdriver.fill",
            tone: Pigment.sky,
            titleKey: "onboarding.2.title",
            textKey: "onboarding.2.text"
        ),
        Slide(
            symbol: "magnifyingglass.circle.fill",
            tone: Pigment.beige,
            titleKey: "onboarding.3.title",
            textKey: "onboarding.3.text"
        ),
        Slide(
            symbol: "questionmark.bubble.fill",
            tone: Pigment.gold,
            titleKey: "onboarding.4.title",
            textKey: "onboarding.4.text"
        )
    ]

    var body: some View {
        ZStack {
            Pigment.heroGrad.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                TabView(selection: $pageIdx) {
                    ForEach(slides.indices, id: \.self) { i in
                        slideBoard(slides[i])
                            .padding(.horizontal, 24)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.interpolatingSpring(stiffness: 180, damping: 18), value: pageIdx)

                pageDots

                primaryButton
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            if pageIdx < slides.count - 1 {
                Button {
                    finish()
                } label: {
                    Text("onboarding.skip")
                        .font(.towerCap)
                        .foregroundStyle(Pigment.textMid)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(Pigment.panel.opacity(0.6))
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .frame(height: 48)
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(slides.indices, id: \.self) { i in
                Capsule()
                    .fill(i == pageIdx ? Pigment.gold : Pigment.stoneDeep.opacity(0.6))
                    .frame(width: i == pageIdx ? 28 : 10, height: 8)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 20), value: pageIdx)
            }
        }
        .padding(.top, 8)
    }

    private var primaryButton: some View {
        Button {
            withAnimation(.interpolatingSpring(stiffness: 180, damping: 18)) {
                if pageIdx < slides.count - 1 {
                    pageIdx += 1
                } else {
                    finish()
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(pageIdx < slides.count - 1 ? "onboarding.next" : "onboarding.start")
                Image(systemName: pageIdx < slides.count - 1 ? "arrow.right" : "sparkles")
            }
            .primaryGoldButton()
        }
    }

    private func slideBoard(_ s: Slide) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 0)
            ZStack {
                Circle()
                    .fill(s.tone.opacity(0.15))
                    .frame(width: 220, height: 220)
                Circle()
                    .stroke(s.tone.opacity(0.45), lineWidth: 2)
                    .frame(width: 240, height: 240)
                Image(systemName: s.symbol)
                    .font(.system(size: 96, weight: .bold))
                    .foregroundStyle(s.tone)
                    .shadow(color: s.tone.opacity(0.45), radius: 20)
            }

            VStack(spacing: 12) {
                Text(LocalizedStringKey(s.titleKey))
                    .font(.towerHero)
                    .foregroundStyle(Pigment.textHi)
                    .multilineTextAlignment(.center)
                Text(LocalizedStringKey(s.textKey))
                    .font(.towerLead)
                    .foregroundStyle(Pigment.textMid)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            Spacer(minLength: 0)
        }
    }

    private func finish() {
        withAnimation(.interpolatingSpring(stiffness: 180, damping: 18)) {
            index.markOnboardingDone()
        }
    }

    private struct Slide: Hashable {
        let symbol: String
        let tone: Color
        let titleKey: String
        let textKey: String
    }
}

#Preview {
    OnboardingView()
        .environmentObject(JourneyIndex(storage: UserDefaults(suiteName: "preview") ?? .standard))
}
