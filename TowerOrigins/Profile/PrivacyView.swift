import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let url = URL(string: AppConfig.privacyPolicyURL) {
                    BridgeWebView(url: url)
                } else {
                    fallback
                }
            }
            .background(Pigment.navy.ignoresSafeArea())
            .navigationTitle("info.privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Pigment.navy, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sheet.close") { dismiss() }
                        .foregroundStyle(Pigment.gold)
                }
            }
        }
    }

    private var fallback: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(Pigment.gold)
            Text("info.privacy")
                .font(.towerH2)
                .foregroundStyle(Pigment.textHi)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
