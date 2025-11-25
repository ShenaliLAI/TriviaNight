import Foundation

struct TriviaQuestion: Codable, Identifiable, Equatable {
    let id: Int
    let category: String
    let difficulty: String
    let question: String
    let options: [String] // always 4 items
    let correctIndex: Int
}
