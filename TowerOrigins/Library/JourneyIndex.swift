import Foundation
import SwiftUI

@MainActor
final class JourneyIndex: ObservableObject {
    private enum Lane {
        static let onboardingDone = "lib::onboarding.done"
        static let favorites      = "lib::favorites"
        static let viewed         = "lib::viewed"
        static let quizBest       = "lib::quiz.score.best"
        static let haptics        = "lib::settings.haptics"
    }

    @Published var onboardingDone: Bool
    @Published var favoriteIDs: Set<String>
    @Published var viewedIDs: Set<String>
    @Published var quizBest: Int
    @Published var hapticsOn: Bool

    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {
        self.storage = storage
        self.onboardingDone = storage.bool(forKey: Lane.onboardingDone)
        self.favoriteIDs = Set(storage.stringArray(forKey: Lane.favorites) ?? [])
        self.viewedIDs = Set(storage.stringArray(forKey: Lane.viewed) ?? [])
        self.quizBest = storage.integer(forKey: Lane.quizBest)
        self.hapticsOn = storage.object(forKey: Lane.haptics) as? Bool ?? true
    }

    func archive() {
        storage.set(onboardingDone, forKey: Lane.onboardingDone)
        storage.set(Array(favoriteIDs), forKey: Lane.favorites)
        storage.set(Array(viewedIDs), forKey: Lane.viewed)
        storage.set(quizBest, forKey: Lane.quizBest)
        storage.set(hapticsOn, forKey: Lane.haptics)
    }

    func unarchive() {
        onboardingDone = storage.bool(forKey: Lane.onboardingDone)
        favoriteIDs = Set(storage.stringArray(forKey: Lane.favorites) ?? [])
        viewedIDs = Set(storage.stringArray(forKey: Lane.viewed) ?? [])
        quizBest = storage.integer(forKey: Lane.quizBest)
        hapticsOn = storage.object(forKey: Lane.haptics) as? Bool ?? true
    }

    func markOnboardingDone() {
        onboardingDone = true
        archive()
    }

    func toggleFavorite(_ id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        archive()
    }

    func isFavorite(_ id: String) -> Bool {
        favoriteIDs.contains(id)
    }

    func markViewed(_ id: String) {
        guard !viewedIDs.contains(id) else { return }
        viewedIDs.insert(id)
        archive()
    }

    func recordQuizScore(_ score: Int) -> Bool {
        guard score > quizBest else { return false }
        quizBest = score
        archive()
        return true
    }

    func setHaptics(_ on: Bool) {
        hapticsOn = on
        archive()
    }
}
