import Foundation
import Combine

final class TriviaManager: ObservableObject {
    private let questionSetNames: [String] = ["questions"]
    private var usedQuestionSetIndices: [Int] = []
    private let questionLimit: Int?

    @Published private(set) var questions: [TriviaQuestion] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var correctCount: Int = 0

    init(questionLimit: Int? = nil) {
        self.questionLimit = questionLimit
        loadQuestions()
    }

    func loadQuestions() {
        let resourceName: String

        if questionSetNames.isEmpty {
            resourceName = "questions"
        } else {
            if usedQuestionSetIndices.count == questionSetNames.count {
                usedQuestionSetIndices.removeAll()
            }

            let availableIndices = questionSetNames.indices.filter { index in
                !usedQuestionSetIndices.contains(index)
            }

            let chosenIndex = availableIndices.randomElement() ?? 0
            usedQuestionSetIndices.append(chosenIndex)
            resourceName = questionSetNames[chosenIndex]
        }

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            print("\(resourceName).json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            var decoded = try JSONDecoder().decode([TriviaQuestion].self, from: data).shuffled()
            if let limit = questionLimit, limit > 0, decoded.count > limit {
                decoded = Array(decoded.prefix(limit))
            }
            DispatchQueue.main.async {
                self.questions = decoded
                self.reset()
            }
        } catch {
            print("Failed to load questions from \(resourceName).json: \(error)")
        }
    }

    var currentQuestion: TriviaQuestion? {
        guard currentIndex >= 0 && currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var totalQuestions: Int { questions.count }

    func goToNextQuestion() {
        guard currentIndex + 1 < questions.count else { return }
        currentIndex += 1
    }

    func recordAnswer(selectedIndex: Int) {
        guard let question = currentQuestion else { return }
        if selectedIndex == question.correctIndex {
            // Simple scoring: +1 point per correct answer
            score += 1
            correctCount += 1
        }
    }

    func reset() {
        currentIndex = 0
        score = 0
        correctCount = 0
    }
}
