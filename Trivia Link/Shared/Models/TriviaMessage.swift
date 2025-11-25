import Foundation

enum TriviaMessage: Codable, Equatable {
    case join(player: Player)
    case playerList([Player])
    case startGame(totalQuestions: Int)
    case question(TriviaQuestion)
    case answer(questionID: Int, playerID: UUID, selectedIndex: Int, timestamp: TimeInterval)
    case reveal(correctIndex: Int, scores: [UUID: Int])
    case gameOver(finalScores: [UUID: Int])
    case ping

    private enum CodingKeys: String, CodingKey {
        case type
        case payload
    }

    private enum MessageType: String, Codable {
        case join
        case playerList
        case startGame
        case question
        case answer
        case reveal
        case gameOver
        case ping
    }

    private struct AnswerPayload: Codable, Equatable {
        let questionID: Int
        let playerID: UUID
        let selectedIndex: Int
        let timestamp: TimeInterval
    }

    private struct RevealPayload: Codable, Equatable {
        let correctIndex: Int
        let scores: [UUID: Int]
    }

    private struct GameOverPayload: Codable, Equatable {
        let finalScores: [UUID: Int]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .join(let player):
            try container.encode(MessageType.join, forKey: .type)
            try container.encode(player, forKey: .payload)

        case .playerList(let players):
            try container.encode(MessageType.playerList, forKey: .type)
            try container.encode(players, forKey: .payload)

        case .startGame(let totalQuestions):
            try container.encode(MessageType.startGame, forKey: .type)
            try container.encode(totalQuestions, forKey: .payload)

        case .question(let question):
            try container.encode(MessageType.question, forKey: .type)
            try container.encode(question, forKey: .payload)

        case .answer(let questionID, let playerID, let selectedIndex, let timestamp):
            try container.encode(MessageType.answer, forKey: .type)
            let payload = AnswerPayload(questionID: questionID, playerID: playerID, selectedIndex: selectedIndex, timestamp: timestamp)
            try container.encode(payload, forKey: .payload)

        case .reveal(let correctIndex, let scores):
            try container.encode(MessageType.reveal, forKey: .type)
            let payload = RevealPayload(correctIndex: correctIndex, scores: scores)
            try container.encode(payload, forKey: .payload)

        case .gameOver(let finalScores):
            try container.encode(MessageType.gameOver, forKey: .type)
            let payload = GameOverPayload(finalScores: finalScores)
            try container.encode(payload, forKey: .payload)

        case .ping:
            try container.encode(MessageType.ping, forKey: .type)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)

        switch type {
        case .join:
            let player = try container.decode(Player.self, forKey: .payload)
            self = .join(player: player)

        case .playerList:
            let players = try container.decode([Player].self, forKey: .payload)
            self = .playerList(players)

        case .startGame:
            let totalQuestions = try container.decode(Int.self, forKey: .payload)
            self = .startGame(totalQuestions: totalQuestions)

        case .question:
            let question = try container.decode(TriviaQuestion.self, forKey: .payload)
            self = .question(question)

        case .answer:
            let payload = try container.decode(AnswerPayload.self, forKey: .payload)
            self = .answer(questionID: payload.questionID, playerID: payload.playerID, selectedIndex: payload.selectedIndex, timestamp: payload.timestamp)

        case .reveal:
            let payload = try container.decode(RevealPayload.self, forKey: .payload)
            self = .reveal(correctIndex: payload.correctIndex, scores: payload.scores)

        case .gameOver:
            let payload = try container.decode(GameOverPayload.self, forKey: .payload)
            self = .gameOver(finalScores: payload.finalScores)

        case .ping:
            self = .ping
        }
    }
}
