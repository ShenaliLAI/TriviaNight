import SwiftUI

struct TimerBar: View {
    let progress: Double // 0.0 - 1.0
    let remainingSeconds: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 12)
                Capsule()
                    .fill(progressColor)
                    .frame(width: nil, height: 12)
                    .scaleEffect(x: max(0.0, min(1.0, progress)), y: 1.0, anchor: .leading)
                    .animation(.linear(duration: 0.1), value: progress)
            }
            Text("\(remainingSeconds)s left")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Time remaining: \(remainingSeconds) seconds")
    }

    private var progressColor: Color {
        switch progress {
        case 0.0..<0.34: return .red
        case 0.34..<0.67: return .yellow
        default: return .green
        }
    }
}
