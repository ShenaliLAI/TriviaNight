import Foundation

enum SeedData {
    static func samplePlayers() -> [Player] {
        [
            Player(name: "Alex", avatar: "🦊"),
            Player(name: "Bella", avatar: "🐼"),
            Player(name: "Charlie", avatar: "🐵"),
            Player(name: "Dana", avatar: "🦁")
        ]
    }

    static func sampleQuestions(bundle: Bundle = .main) -> [TriviaQuestion] {
        if let url = bundle.url(forResource: "questions", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let questions = try? TriviaManager.loadQuestions(from: data) {
            return questions
        }
        // Fallback minimal inline questions if JSON is missing in the test environment.
        return [
            TriviaQuestion(id: 1,
                           category: "General",
                           difficulty: "easy",
                           question: "What color is grass?",
                           options: ["Blue", "Green", "Red", "Yellow"],
                           correctIndex: 1)
        ]
    }
}
