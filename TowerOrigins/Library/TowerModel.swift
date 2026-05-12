import Foundation

struct Tower: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let kind: TowerKind
    let era: Era
    let location: String
    let centuryLabel: String
    let brief: String
    let fact: String
    let imageName: String
    let buildStages: [BuildStage]
    let interiorNotes: [InteriorNote]
    let historicFacts: [HistoricFact]
    let popularityRank: Int
}

enum TowerKind: String, Codable, CaseIterable, Hashable, Identifiable {
    case castle, watchtower, bell, clock, fortress, lighthouse, medieval

    var id: String { rawValue }

    var localizationKey: String { "kind.\(rawValue)" }

    var symbol: String {
        switch self {
        case .castle:     return "shield.lefthalf.filled"
        case .watchtower: return "binoculars.fill"
        case .bell:       return "bell.fill"
        case .clock:      return "clock.fill"
        case .fortress:   return "building.columns.fill"
        case .lighthouse: return "lightbulb.led.fill"
        case .medieval:   return "crown.fill"
        }
    }
}

enum Era: String, Codable, CaseIterable, Hashable, Identifiable {
    case ancient, medieval, renaissance, earlyModern

    var id: String { rawValue }

    var localizationKey: String { "era.\(rawValue)" }
}

struct BuildStage: Codable, Hashable {
    let order: Int
    let title: String
    let description: String
}

struct InteriorNote: Codable, Hashable {
    let title: String
    let description: String
}

struct HistoricFact: Codable, Hashable {
    let year: String?
    let description: String
}
