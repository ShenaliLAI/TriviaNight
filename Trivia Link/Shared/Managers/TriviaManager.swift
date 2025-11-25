import Foundation
import Combine

final class TriviaManager: ObservableObject {
    struct PlayerAnswer: Equatable {
        let playerID: UUID
        let questionID: Int
        let selectedIndex: Int
        let timestamp: TimeInterval
    }

    @Published private(set) var questions: [TriviaQuestion]
    @Published private(set) var currentQuestionIndex: Int = 0
    @Published private(set) var players: [Player] = []
    @Published private(set) var isGameOver: Bool = false

    // Tracks how many times a player was the single fastest correct responder.
    private(set) var fastestCorrectCounts: [UUID: Int] = [:]

    // Tracks the latest answer timestamp per player for tie-breaking.
    private(set) var lastAnswerTimestamps: [UUID: TimeInterval] = [:]

    init(questions: [TriviaQuestion] = []) {
        self.questions = questions
    }

    // MARK: - Question loading

    static func loadQuestions(from data: Data) throws -> [TriviaQuestion] {
        let decoder = JSONDecoder()
        return try decoder.decode([TriviaQuestion].self, from: data)
    }

    static func loadQuestions(from url: URL) throws -> [TriviaQuestion] {
        let data = try Data(contentsOf: url)
        return try loadQuestions(from: data)
    }

    static func loadDefaultQuestions(bundle: Bundle = .main) throws -> [TriviaQuestion] {
        guard let url = bundle.url(forResource: "questions", withExtension: "json") else {
            throw NSError(domain: "TriviaManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "questions.json not found in bundle"])
        }
        return try loadQuestions(from: url)
    }

    func resetGame(with questions: [TriviaQuestion]? = nil) {
        if let newQuestions = questions {
            self.questions = newQuestions
        }
        currentQuestionIndex = 0
        isGameOver = false
        fastestCorrectCounts.removeAll()
        lastAnswerTimestamps.removeAll()
        players = players.map { player in
            var updated = player
            updated.score = 0
            return updated
        }
    }

    // MARK: - Player management

    func register(player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
        } else {
            players.append(player)
        }
    }

    func removePlayer(id: UUID) {
        players.removeAll { $0.id == id }
        fastestCorrectCounts[id] = nil
        lastAnswerTimestamps[id] = nil
    }

    func updateConnectionStatus(for id: UUID, isConnected: Bool) {
        guard let index = players.firstIndex(where: { $0.id == id }) else { return }
        players[index].isConnected = isConnected
    }

    // MARK: - Game progression

    var currentQuestion: TriviaQuestion? {
        guard currentQuestionIndex >= 0 && currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var totalQuestions: Int {
        questions.count
    }

    func advanceToNextQuestion() {
        guard currentQuestionIndex + 1 < questions.count else {
            isGameOver = true
            return
        }
        currentQuestionIndex += 1
    }

    // MARK: - Scoring

    /// Applies scoring for a single question based on the provided answers.
    /// - Parameters:
    ///   - question: The question being scored.
    ///   - answers: All answers received for this question.
    /// - Returns: A dictionary of playerID to updated total score after this question.
    func score(question: TriviaQuestion, answers: [PlayerAnswer]) -> [UUID: Int] {
        // Filter to correct answers and order by timestamp ascending.
        let correctAnswers = answers.filter { $0.questionID == question.id && $0.selectedIndex == question.correctIndex }
        let sortedCorrect = correctAnswers.sorted { $0.timestamp < $1.timestamp }

        var scoreDeltas: [UUID: Int] = [:]

        for (index, answer) in sortedCorrect.enumerated() {
            var delta = 100
            switch index {
            case 0:
                delta += 20
                fastestCorrectCounts[answer.playerID, default: 0] += 1
            case 1:
                delta += 10
            case 2:
                delta += 5
            default:
                break
            }
            scoreDeltas[answer.playerID, default: 0] += delta
            lastAnswerTimestamps[answer.playerID] = answer.timestamp
        }

        // Track timestamps even for incorrect answers for tie-breaking.
        for answer in answers {
            if lastAnswerTimestamps[answer.playerID] == nil || lastAnswerTimestamps[answer.playerID]! < answer.timestamp {
                lastAnswerTimestamps[answer.playerID] = answer.timestamp
            }
        }

        // Apply deltas to players and build totals dictionary.
        var totals: [UUID: Int] = [:]

        for index in players.indices {
            let id = players[index].id
            if let delta = scoreDeltas[id] {
                players[index].score += delta
            }
            totals[id] = players[index].score
        }

        return totals
    }

    /// Returns players sorted for leaderboard presentation.
    /// Order: score desc, fastest-correct count desc, earliest lastAnswerTimestamp asc.
    func leaderboard() -> [Player] {
        return players.sorted { lhs, rhs in
            if lhs.score != rhs.score {
                return lhs.score > rhs.score
            }
            let lhsFast = fastestCorrectCounts[lhs.id, default: 0]
            let rhsFast = fastestCorrectCounts[rhs.id, default: 0]
            if lhsFast != rhsFast {
                return lhsFast > rhsFast
            }
            let lhsTime = lastAnswerTimestamps[lhs.id] ?? .greatestFiniteMagnitude
            let rhsTime = lastAnswerTimestamps[rhs.id] ?? .greatestFiniteMagnitude
            if lhsTime != rhsTime {
                return lhsTime < rhsTime
            }
            return lhs.name < rhs.name
        }
    }
}
