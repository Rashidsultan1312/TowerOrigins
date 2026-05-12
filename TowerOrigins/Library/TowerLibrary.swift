import Foundation
import SwiftUI

@MainActor
final class TowerLibrary: ObservableObject {
    @Published private(set) var towers: [Tower]

    @Published var searchQuery: String = ""
    @Published var kindFilters: Set<TowerKind> = []
    @Published var eraFilters: Set<Era> = []

    init() {
        self.towers = BundledCatalog.loadTowers()
    }

    var filtered: [Tower] {
        towers
            .filter { tower in
                guard kindFilters.isEmpty || kindFilters.contains(tower.kind) else { return false }
                guard eraFilters.isEmpty || eraFilters.contains(tower.era) else { return false }
                let q = searchQuery.trimmingCharacters(in: .whitespaces).lowercased()
                guard !q.isEmpty else { return true }
                return tower.name.lowercased().contains(q)
                    || tower.location.lowercased().contains(q)
                    || tower.brief.lowercased().contains(q)
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var popular: [Tower] {
        towers
            .sorted { $0.popularityRank < $1.popularityRank }
            .prefix(8)
            .map { $0 }
    }

    var featured: Tower? {
        guard !towers.isEmpty else { return nil }
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let pool = towers.sorted { $0.popularityRank < $1.popularityRank }
        return pool[dayOfYear % pool.count]
    }

    var activeFilterCount: Int {
        kindFilters.count + eraFilters.count
    }

    func tower(byID id: String) -> Tower? {
        towers.first { $0.id == id }
    }

    func clearFilters() {
        kindFilters.removeAll()
        eraFilters.removeAll()
    }

    func toggleKind(_ kind: TowerKind) {
        if kindFilters.contains(kind) {
            kindFilters.remove(kind)
        } else {
            kindFilters.insert(kind)
        }
    }

    func toggleEra(_ era: Era) {
        if eraFilters.contains(era) {
            eraFilters.remove(era)
        } else {
            eraFilters.insert(era)
        }
    }
}
