import Foundation

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: String
    let prompt: String
    let options: [String]
    let answerIndex: Int
    let explanation: String
}

struct QuizSession {
    var questions: [QuizQuestion]
    var currentIndex: Int = 0
    var score: Int = 0
    var answers: [Int: Int] = [:]

    var current: QuizQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var total: Int { questions.count }

    var isLast: Bool { currentIndex >= questions.count - 1 }

    var finished: Bool { currentIndex >= questions.count }

    static func make(from deck: [QuizQuestion], limit: Int = 15) -> QuizSession {
        let shuffled = Array(deck.shuffled().prefix(limit))
        return QuizSession(questions: shuffled)
    }

    mutating func answer(_ choice: Int) -> Bool {
        guard let q = current else { return false }
        answers[currentIndex] = choice
        let correct = choice == q.answerIndex
        if correct { score += 1 }
        return correct
    }

    mutating func advance() {
        currentIndex += 1
    }
}
