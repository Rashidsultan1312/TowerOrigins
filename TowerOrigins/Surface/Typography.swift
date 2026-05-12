import SwiftUI

extension Font {
    static let towerHero = Font.system(size: 30, weight: .heavy, design: .rounded)
    static let towerH1   = Font.system(size: 24, weight: .heavy, design: .rounded)
    static let towerH2   = Font.system(size: 20, weight: .bold, design: .rounded)
    static let towerH3   = Font.system(size: 17, weight: .bold, design: .rounded)
    static let towerBody = Font.system(size: 15, weight: .regular, design: .rounded)
    static let towerLead = Font.system(size: 16, weight: .medium, design: .rounded)
    static let towerCap  = Font.system(size: 12, weight: .semibold, design: .rounded)
    static let towerScore = Font.system(size: 64, weight: .black, design: .rounded).monospacedDigit()
    static let towerCounter = Font.system(size: 28, weight: .heavy, design: .rounded).monospacedDigit()
}
