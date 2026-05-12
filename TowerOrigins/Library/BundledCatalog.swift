import Foundation

enum BundledCatalog {
    static func loadTowers() -> [Tower] {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        let decoder = JSONDecoder()
        return (try? decoder.decode([Tower].self, from: data)) ?? []
    }

    static func loadQuiz() -> [QuizQuestion] {
        guard let url = Bundle.main.url(forResource: "quiz", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        let decoder = JSONDecoder()
        return (try? decoder.decode([QuizQuestion].self, from: data)) ?? []
    }
}
