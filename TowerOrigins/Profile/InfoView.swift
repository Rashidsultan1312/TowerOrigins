import SwiftUI

struct InfoView: View {
    @EnvironmentObject private var index: JourneyIndex
    @State private var showPrivacy: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                aboutBlock

                section("info.settings") {
                    Toggle(isOn: Binding(
                        get: { index.hapticsOn },
                        set: { index.setHaptics($0) }
                    )) {
                        Label("info.haptics", systemImage: "wave.3.right")
                            .foregroundStyle(Pigment.textHi)
                    }
                    .tint(Pigment.gold)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Pigment.panelGrad)
                    )
                }

                section("info.about") {
                    listRow(symbol: "lock.shield.fill",
                            titleKey: "info.privacy",
                            tone: Pigment.sky) {
                        showPrivacy = true
                    }

                    if let url = URL(string: "mailto:\(AppConfig.supportEmail)") {
                        Link(destination: url) {
                            listRowContent(symbol: "envelope.fill",
                                           titleKey: "info.support",
                                           subtitleKey: "info.support.subtitle",
                                           tone: Pigment.beige)
                        }
                        .buttonStyle(.plain)
                    }

                    versionRow
                }
            }
            .padding(20)
        }
        .background(Pigment.heroGrad.ignoresSafeArea())
        .navigationTitle("info.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Pigment.navy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .fullScreenCover(isPresented: $showPrivacy) {
            PrivacyView()
        }
    }

    private var aboutBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Pigment.goldGrad)
                        .frame(width: 64, height: 64)
                        .shadow(color: Pigment.gold.opacity(0.4), radius: 8)
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(Pigment.navy)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("info.about.title")
                        .font(.towerH2)
                        .foregroundStyle(Pigment.textHi)
                    Text(versionLine)
                        .font(.towerCap)
                        .foregroundStyle(Pigment.textMid)
                }
            }
            Text("info.about.text")
                .font(.towerBody)
                .foregroundStyle(Pigment.textMid)
        }
        .stonePanel(elevated: true)
    }

    private func section<Content: View>(_ titleKey: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey(titleKey))
                .font(.towerH3)
                .foregroundStyle(Pigment.textMid)
                .textCase(.uppercase)
                .padding(.leading, 4)
            content()
        }
    }

    private func listRow(symbol: String, titleKey: String, tone: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            listRowContent(symbol: symbol, titleKey: titleKey, subtitleKey: nil, tone: tone)
        }
        .buttonStyle(.plain)
    }

    private func listRowContent(symbol: String, titleKey: String, subtitleKey: String?, tone: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(tone.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(tone)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(titleKey))
                    .font(.towerH3)
                    .foregroundStyle(Pigment.textHi)
                if let s = subtitleKey {
                    Text(LocalizedStringKey(s))
                        .font(.towerCap)
                        .foregroundStyle(Pigment.textMid)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Pigment.textMid)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Pigment.panelGrad)
        )
    }

    private var versionRow: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Pigment.gold.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: "tag.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Pigment.gold)
            }
            Text(String(format: NSLocalizedString("info.version", comment: ""), shortVersion))
                .font(.towerH3)
                .foregroundStyle(Pigment.textHi)
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Pigment.panelGrad)
        )
    }

    private var versionLine: String {
        String(format: NSLocalizedString("info.version", comment: ""), shortVersion)
    }

    private var shortVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
