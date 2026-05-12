import Foundation

enum QuizDeck {
    static func load() -> [QuizQuestion] {
        BundledCatalog.loadQuiz()
    }

    static func makeSession(limit: Int = 15) -> QuizSession {
        QuizSession.make(from: load(), limit: limit)
    }
}
