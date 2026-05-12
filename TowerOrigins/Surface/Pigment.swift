import SwiftUI

enum Pigment {
    static let sky        = Color(hex: 0x5BB4D6)
    static let skyDeep    = Color(hex: 0x2C6F94)
    static let navy       = Color(hex: 0x0F1B24)
    static let surface    = Color(hex: 0x172638)
    static let panel      = Color(hex: 0x1E3146)
    static let panelHi    = Color(hex: 0x274160)
    static let gold       = Color(hex: 0xFDD84A)
    static let goldDeep   = Color(hex: 0xE6B920)
    static let stone      = Color(hex: 0xA8A39B)
    static let stoneDeep  = Color(hex: 0x6F6A62)
    static let beige      = Color(hex: 0xEFE3CC)
    static let wood       = Color(hex: 0x6B4423)
    static let textHi     = Color(hex: 0xF6F0E1)
    static let textMid    = Color(hex: 0xC8B89C)
    static let textLow    = Color(hex: 0x7B7066)
    static let win        = Color(hex: 0x6FC97A)
    static let loss       = Color(hex: 0xE07A6B)

    static let heroGrad = LinearGradient(
        colors: [Color(hex: 0x0F1B24), Color(hex: 0x172638), Color(hex: 0x2C6F94).opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let goldGrad = LinearGradient(
        colors: [Color(hex: 0xFDD84A), Color(hex: 0xE6B920)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panelGrad = LinearGradient(
        colors: [Color(hex: 0x1E3146), Color(hex: 0x172638)],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

struct StonePanelStyle: ViewModifier {
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Pigment.panelGrad)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Pigment.gold.opacity(elevated ? 0.45 : 0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(elevated ? 0.35 : 0.18),
                    radius: elevated ? 12 : 6,
                    x: 0,
                    y: elevated ? 6 : 3)
    }
}

struct GoldGlowText: ViewModifier {
    var radius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .foregroundStyle(Pigment.gold)
            .shadow(color: Pigment.gold.opacity(0.55), radius: radius)
            .shadow(color: Pigment.goldDeep.opacity(0.35), radius: radius / 2)
    }
}

struct PrimaryGoldButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.headline, design: .rounded, weight: .heavy))
            .foregroundStyle(Pigment.navy)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Pigment.goldGrad)
            )
            .shadow(color: Pigment.gold.opacity(0.35), radius: 14, y: 6)
    }
}

extension View {
    func stonePanel(elevated: Bool = false) -> some View {
        modifier(StonePanelStyle(elevated: elevated))
    }

    func goldGlow(radius: CGFloat = 14) -> some View {
        modifier(GoldGlowText(radius: radius))
    }

    func primaryGoldButton() -> some View {
        modifier(PrimaryGoldButton())
    }
}
