import Foundation

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var avatar: String // emoji or asset name
    var score: Int
    var isConnected: Bool

    init(id: UUID = UUID(), name: String, avatar: String, score: Int = 0, isConnected: Bool = true) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.score = score
        self.isConnected = isConnected
    }
}
