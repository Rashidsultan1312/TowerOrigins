import SwiftUI

struct InteriorView: View {
    let tower: Tower
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ArchiveCarousel(prefix: "\(tower.imageName)_interior")

                    Text(tower.name)
                        .font(.towerH2)
                        .foregroundStyle(Pigment.textHi)

                    ForEach(tower.interiorNotes, id: \.title) { note in
                        InteriorRow(note: note)
                    }
                }
                .padding(20)
            }
            .background(Pigment.heroGrad.ignoresSafeArea())
            .navigationTitle("sheet.interior.title")
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

private struct InteriorRow: View {
    let note: InteriorNote

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Pigment.beige.opacity(0.18))
                    .frame(width: 42, height: 42)
                Image(systemName: "door.left.hand.open")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Pigment.beige)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(note.title)
                    .font(.towerH3)
                    .foregroundStyle(Pigment.textHi)
                Text(note.description)
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
                .stroke(Pigment.beige.opacity(0.25), lineWidth: 1)
        )
    }
}

struct ArchiveCarousel: View {
    let prefix: String
    var maxSlides: Int = 4

    @State private var slot: Int = 0

    private var available: [String] {
        (1...maxSlides)
            .map { "\(prefix)_\($0)" }
            .filter { UIImage(named: $0) != nil }
    }

    var body: some View {
        let frames = available
        if frames.isEmpty {
            EmptyView()
        } else {
            VStack(spacing: 8) {
                TabView(selection: $slot) {
                    ForEach(Array(frames.enumerated()), id: \.offset) { i, name in
                        Color.clear
                            .aspectRatio(16.0/10.0, contentMode: .fit)
                            .overlay(
                                Image(uiImage: UIImage(named: name)!)
                                    .resizable()
                                    .scaledToFill()
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Pigment.gold.opacity(0.25), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .aspectRatio(16.0/10.0, contentMode: .fit)
                .frame(maxWidth: .infinity)

                if frames.count > 1 {
                    HStack(spacing: 6) {
                        ForEach(0..<frames.count, id: \.self) { i in
                            Capsule()
                                .fill(i == slot ? Pigment.gold : Pigment.stoneDeep.opacity(0.5))
                                .frame(width: i == slot ? 18 : 6, height: 6)
                                .animation(.interpolatingSpring(stiffness: 200, damping: 20), value: slot)
                        }
                    }
                }
            }
        }
    }
}
