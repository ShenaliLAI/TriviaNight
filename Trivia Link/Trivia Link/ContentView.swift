//
//  ContentView.swift
//  Trivia Link
//
//  Created by STUDENT on 2025-11-24.
//

import SwiftUI
 
struct ContentView: View {
    @State private var numberOfPlayers: Int = 1
    @State private var playerNames: [String] = ["Player 1", "Player 2", "Player 3", "Player 4"]
    @State private var animateTitle: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.black.opacity(0.8), Color.blue.opacity(0.7)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
                KidsAnimationBackground()
                    .allowsHitTesting(false)

                VStack(spacing: 40) {
                    Text("TriviaNightTV")
                        .font(.largeTitle)
                        .bold()
                        .scaleEffect(animateTitle ? 1.06 : 0.96)
                        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: animateTitle)

                    Text("Press Play on the remote to start hosting a trivia game.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 80)

                    NavigationLink {
                        LobbyView(numberOfPlayers: $numberOfPlayers, playerNames: $playerNames)
                    } label: {
                        Text("Host New Game")
                            .font(.title2)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Host new trivia game")
                    .accessibilityHint("Opens the lobby where players can join.")
                }
                .foregroundColor(.white)
            }
        }
        .onAppear {
            animateTitle = true
        }
    }
}

struct LobbyView: View {
    @Binding var numberOfPlayers: Int
    @Binding var playerNames: [String]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black.opacity(0.8), Color.blue.opacity(0.7)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()

            VStack(spacing: 32) {
                HStack(spacing: 16) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    Text("Lobby")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                }

                Text("Play together on this Apple TV. Take turns answering questions using the remote.")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)

                HStack(spacing: 24) {
                    Button {
                        if numberOfPlayers > 1 { numberOfPlayers -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }

                    Text("Players: \(numberOfPlayers)")
                        .font(.title3)
                        .foregroundColor(.white)

                    Button {
                        if numberOfPlayers < 4 { numberOfPlayers += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }

                VStack(spacing: 12) {
                    ForEach(0..<numberOfPlayers, id: \.self) { index in
                        TextField("Player \(index + 1) Name", text: $playerNames[index])
                            .font(.title3)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 80)
                    }
                }

                Spacer()

                NavigationLink {
                    QuestionView(numberOfPlayers: numberOfPlayers,
                                 playerNames: Array(playerNames.prefix(numberOfPlayers)))
                } label: {
                    Text("Start Game")
                        .font(.title2)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.bottom, 40)
            }
            .padding(.top, 60)
        }
    }
}

#Preview {
    ContentView()
}

struct QuestionView: View {
    let numberOfPlayers: Int
    let playerNames: [String]
    @StateObject private var triviaManager: TriviaManager
    @State private var selectedIndex: Int? = nil
    @State private var isRevealed: Bool = false
    @State private var showResults: Bool = false
    @State private var currentPlayerIndex: Int = 0
    @State private var playerScores: [Int] = []

    init(numberOfPlayers: Int, playerNames: [String]) {
        self.numberOfPlayers = numberOfPlayers
        self.playerNames = playerNames
        let limit = QuestionView.questionLimit(for: numberOfPlayers)
        _triviaManager = StateObject(wrappedValue: TriviaManager(questionLimit: limit))
    }

    private static func questionLimit(for players: Int) -> Int {
        switch players {
        case 2:
            return 10
        case 3:
            return 12
        case 4:
            return 20
        default:
            return 10
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple.opacity(0.9), Color.black.opacity(0.9)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()

            if showResults {
                ResultView(playerScores: playerScores,
                           totalQuestions: triviaManager.totalQuestions,
                           playerNames: playerNames) {
                    playAgain()
                }
            } else if let question = triviaManager.currentQuestion {
                VStack(spacing: 32) {
                    Text("Question \(triviaManager.currentIndex + 1) of \(max(triviaManager.totalQuestions, 1))")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    Text("\(name(for: currentPlayerIndex))'s turn")
                        .font(.title3)
                        .foregroundColor(.white)

                    Text(question.question)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 80)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    let columns = [GridItem(.flexible(), spacing: 24), GridItem(.flexible(), spacing: 24)]

                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(question.options.indices, id: \.self) { index in
                            let isCorrect = isRevealed ? (index == question.correctIndex) : false
                            Button {
                                // Only score the first tap per question
                                if !isRevealed {
                                    selectedIndex = index
                                    isRevealed = true

                                    // Update per-player score
                                    if index == question.correctIndex,
                                       playerScores.indices.contains(currentPlayerIndex) {
                                        playerScores[currentPlayerIndex] += 1
                                    }

                                    triviaManager.recordAnswer(selectedIndex: index)
                                }
                            } label: {
                                HStack(alignment: .firstTextBaseline, spacing: 20) {
                                    Text(optionLetter(for: index))
                                        .font(.title3)
                                        .bold()
                                    Text(question.options[index])
                                        .font(.title3)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 90)
                                .background(buttonBackground(isSelected: selectedIndex == index, isCorrect: isCorrect))
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(buttonBorder(isSelected: selectedIndex == index, isCorrect: isCorrect), lineWidth: 3)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Answer \(optionLetter(for: index)). \(question.options[index])")
                        }
                    }
                    .padding(.horizontal, 80)

                    if let selected = selectedIndex {
                        Text(selected == question.correctIndex ? "Correct!" : "Nice try, the correct answer is \(question.options[question.correctIndex]).")
                            .font(.title2)
                            .foregroundColor(selected == question.correctIndex ? .green : .red)
                            .padding(.top, 16)
                    }

                    Button {
                        handlePrimaryButtonTap()
                    } label: {
                        Text(triviaManager.currentIndex + 1 < triviaManager.totalQuestions ? "Next Question" : "See Score")
                            .font(.title2)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.top, 8)
                    .disabled(triviaManager.totalQuestions == 0 || selectedIndex == nil)

                    Spacer()
                }
                .padding(.top, 80)
            } else {
                ProgressView("Loading questions...")
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            // Initialize per-player scores for the selected number of players
            let count = max(numberOfPlayers, 1)
            if playerScores.count != count {
                playerScores = Array(repeating: 0, count: count)
            }
        }
    }

    private func name(for index: Int) -> String {
        if playerNames.indices.contains(index) {
            let raw = playerNames[index].trimmingCharacters(in: .whitespacesAndNewlines)
            return raw.isEmpty ? "Player \(index + 1)" : raw
        }
        return "Player \(index + 1)"
    }

    private func optionLetter(for index: Int) -> String {
        let letters = ["A", "B", "C", "D"]
        return index < letters.count ? letters[index] : "?"
    }

    private func buttonBackground(isSelected: Bool, isCorrect: Bool) -> Color {
        if isCorrect { return Color.green.opacity(0.25) }
        if isSelected { return Color.blue.opacity(0.25) }
        return Color.white.opacity(0.12)
    }

    private func buttonBorder(isSelected: Bool, isCorrect: Bool) -> Color {
        if isCorrect { return .green }
        if isSelected { return .blue }
        return .clear
    }
    
    private func handlePrimaryButtonTap() {
        if triviaManager.currentIndex + 1 < triviaManager.totalQuestions {
            goToNextQuestion()
        } else {
            showResults = true
        }
    }

    private func goToNextQuestion() {
        selectedIndex = nil
        isRevealed = false
        if triviaManager.currentIndex + 1 < triviaManager.totalQuestions {
            triviaManager.goToNextQuestion()
        }
        if numberOfPlayers > 0 {
            currentPlayerIndex = (currentPlayerIndex + 1) % numberOfPlayers
        }
    }

    private func playAgain() {
        triviaManager.loadQuestions()
        selectedIndex = nil
        isRevealed = false
        showResults = false
        currentPlayerIndex = 0
        if playerScores.count != max(numberOfPlayers, 1) {
            playerScores = Array(repeating: 0, count: max(numberOfPlayers, 1))
        } else {
            for i in playerScores.indices { playerScores[i] = 0 }
        }
    }
}

struct ResultView: View {
    let playerScores: [Int]
    let totalQuestions: Int
    let playerNames: [String]
    let onPlayAgain: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var animateTrophy = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black.opacity(0.9), Color.blue.opacity(0.9)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()

            ConfettiView()

            VStack(spacing: 24) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 72))
                    .foregroundColor(.yellow)
                    .scaleEffect(animateTrophy ? 1.15 : 0.9)
                    .shadow(color: .yellow.opacity(0.6), radius: animateTrophy ? 22 : 10)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animateTrophy)

                Text("Game Over")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                // Per-player scores
                VStack(spacing: 16) {
                    ForEach(playerScores.indices, id: \.self) { index in
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(displayName(for: index))
                                    .font(.title3)
                                    .bold()
                                Text("\(playerScores[index]) point\(playerScores[index] == 1 ? "" : "s")")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)

                            Spacer()

                            if isWinner(at: index) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding()
                        .frame(maxWidth: 600, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(isWinner(at: index) ? 0.2 : 0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isWinner(at: index) ? Color.yellow : Color.white.opacity(0.3),
                                        lineWidth: isWinner(at: index) ? 3 : 1)
                        )
                    }
                }
                .padding(.horizontal, 80)

                // Winner(s)
                if let maxScore = playerScores.max() {
                    let winners = playerScores.enumerated()
                        .filter { $0.element == maxScore }
                        .map { displayName(for: $0.offset) }
                    let winnerText = winners.joined(separator: ", ")

                    Text(maxScore == 0 ? "No correct answers this time." : "Winner: \(winnerText) with \(maxScore) point\(maxScore == 1 ? "" : "s")")
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                HStack(spacing: 24) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Lobby")
                            .font(.title2)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button {
                        onPlayAgain()
                    } label: {
                        Text("Play Again")
                            .font(.title2)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding(.top, 16)
            }
        }
        .onAppear {
            animateTrophy = true
        }
    }

    private func displayName(for index: Int) -> String {
        guard playerNames.indices.contains(index) else { return "Player \(index + 1)" }
        let raw = playerNames[index].trimmingCharacters(in: .whitespacesAndNewlines)
        return raw.isEmpty ? "Player \(index + 1)" : raw
    }

    private func isWinner(at index: Int) -> Bool {
        guard let maxScore = playerScores.max(), maxScore > 0 else { return false }
        return playerScores.indices.contains(index) && playerScores[index] == maxScore
    }
}

struct ConfettiView: View {
    @State private var animate = false
    private let colors: [Color] = [.yellow, .blue, .green, .pink, .orange]

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<30, id: \.self) { index in
                Circle()
                    .fill(colors[index % colors.count].opacity(0.8))
                    .frame(width: 8, height: 8)
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: animate ? geometry.size.height + 40 : -40
                    )
                    .animation(
                        Animation.linear(duration: 3.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.05),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }
}

struct KidsAnimationBackground: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.35))
                    .frame(width: geometry.size.width * 0.9,
                           height: geometry.size.width * 0.9)
                    .offset(x: animate ? -geometry.size.width * 0.25 : -geometry.size.width * 0.15,
                            y: animate ? -geometry.size.height * 0.35 : -geometry.size.height * 0.25)
                    .blur(radius: 45)
                    .animation(
                        .easeInOut(duration: 10.0)
                            .repeatForever(autoreverses: true),
                        value: animate
                    )

                Circle()
                    .fill(Color.mint.opacity(0.35))
                    .frame(width: geometry.size.width * 0.7,
                           height: geometry.size.width * 0.7)
                    .offset(x: animate ? geometry.size.width * 0.3 : geometry.size.width * 0.2,
                            y: animate ? geometry.size.height * 0.3 : geometry.size.height * 0.2)
                    .blur(radius: 45)
                    .animation(
                        .easeInOut(duration: 9.0)
                            .repeatForever(autoreverses: true)
                            .delay(0.6),
                        value: animate
                    )

                Circle()
                    .fill(Color.yellow.opacity(0.25))
                    .frame(width: geometry.size.width * 0.5,
                           height: geometry.size.width * 0.5)
                    .offset(x: 0,
                            y: animate ? geometry.size.height * 0.12 : -geometry.size.height * 0.12)
                    .blur(radius: 35)
                    .animation(
                        .easeInOut(duration: 11.0)
                            .repeatForever(autoreverses: true)
                            .delay(1.0),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }
}
