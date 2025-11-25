import SwiftUI

struct PlayerRow: View {
    let player: Player

    var body: some View {
        HStack(spacing: 12) {
            Text(player.avatar)
                .font(.largeTitle)
            VStack(alignment: .leading) {
                Text(player.name)
                    .font(.headline)
                Text("Score: \(player.score)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Circle()
                .fill(player.isConnected ? Color.green : Color.gray)
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Player \(player.name), score \(player.score)")
        .accessibilityHint(player.isConnected ? "Connected" : "Disconnected")
    }
}
