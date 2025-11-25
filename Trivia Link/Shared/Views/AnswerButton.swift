import SwiftUI

struct AnswerButton: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(letter)
                    .font(.headline)
                    .bold()
                Text(text)
                    .font(.title3)
                    .lineLimit(2)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(backgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(TVFocusButtonStyle())
        .accessibilityLabel("Answer \(letter). \(text)")
        .accessibilityHint("Double-tap to choose this answer")
    }

    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.1)
        }
        return isSelected ? Color.blue.opacity(0.2) : Color(.secondarySystemBackground)
    }

    private var borderColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : .red
        }
        return isSelected ? .blue : .clear
    }
}

struct TVFocusButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.05)
            .shadow(color: .black.opacity(configuration.isPressed ? 0.1 : 0.3), radius: configuration.isPressed ? 4 : 10, x: 0, y: 6)
            .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.1), value: configuration.isPressed)
    }
}
