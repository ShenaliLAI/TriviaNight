import Foundation

struct TriviaQuestion: Codable, Identifiable {
    let id: Int
    let category: String
    let difficulty: String
    let question: String
    let options: [String] // 4 options
    let correctIndex: Int
}
