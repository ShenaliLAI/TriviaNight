# TriviaNight
MADD Assignment part B

TriviaNightTV

A Local Multiplayer Trivia Game for Kids (tvOS Only)

Overview

TriviaNightTV is a fully local multiplayer trivia game designed for children aged 6 to 12.
The app runs exclusively on tvOS and is controlled entirely with the Apple TV Remote.
Up to four players can participate using a turn-based answering system.

Players select how many participants will play, enter their names, choose avatars, and then compete in a trivia quiz chosen from a randomly shuffled set of questions loaded from a JSON file.

This project is developed according to the requirements of the coursework document:
/mnt/data/Assignment 02 - 2025.pdf.

Key Features
1. Player Count Selection

Choose between 2, 3, or 4 players.

Game length automatically changes:

2 players: 10 questions

3 players: 12 questions

4 players: 20 questions

2. Player Setup

Each player provides:

Name (entered using the tvOS keyboard)

Avatar (selected from a child-friendly emoji set)

3. Game Lobby

A summary of all players before the game begins.
Includes a Start button and a short instructions panel.

4. Trivia Questions

Questions loaded from a bundled JSON file.

Questions are shuffled every session.

Categories include science, animals, space, general knowledge, and kid-friendly topics.

5. Answering System

Turn-based answering using the TV remote.

Each option (A/B/C/D) is presented as a large, easy-to-select button.

Count-down timer per question.

Player strip to track whose turn it is.

6. Reveal and Scoring

After all players answer:

The correct answer is highlighted.

Incorrect answers fade out.

Points are applied based on correctness and speed.

Scoring Rules

Correct answer: 100 points

Fastest correct answer bonus:

First fastest: 20 points

Second fastest: 10 points

Third fastest: 5 points

7. Final Leaderboard

A ranking of players sorted from highest to lowest score with final statistics.

8. Kid-Friendly User Interface

Large fonts

High contrast colors

Clear navigation

Smooth animations

Intuitive UX designed specifically for ages 6–12

Architecture
Technologies Used

Swift

SwiftUI

tvOS Focus Engine

Combine

JSON data loading

Unit and UI testing

Project Structure
TriviaNightTV/
├── Models/
│   ├── Player.swift
│   ├── TriviaQuestion.swift
│   └── TriviaMessage.swift
├── Managers/
│   └── TriviaManager.swift
├── ViewModels/
│   ├── LobbyViewModel.swift
│   ├── GameViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── SplashScreen.swift
│   ├── MainMenuView.swift
│   ├── PlayerCountSelectionView.swift
│   ├── PlayerSetupView.swift
│   ├── GameLobbyView.swift
│   ├── QuestionView.swift
│   ├── RevealView.swift
│   └── FinalLeaderboardView.swift
├── Components/
│   ├── PlayerRow.swift
│   ├── AnswerButton.swift
│   ├── TimerBar.swift
│   ├── AvatarSelector.swift
│   └── ScoreBadge.swift
├── Resources/
│   └── questions.json
├── Tests/
│   ├── TriviaManagerTests.swift
│   └── GameFlowUITests.swift
└── README.md

Game Logic
Trivia Manager

Responsible for:

Loading the JSON file

Shuffling questions

Tracking current question index

Computing scores

Calculating fastest responder bonuses

Data Models
Player
struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatar: String
    var score: Int
    var fastestAnswerCount: Int
}

TriviaQuestion
struct TriviaQuestion: Codable, Identifiable {
    let id: Int
    let category: String
    let difficulty: String
    let question: String
    let options: [String]
    let correctIndex: Int
}

Accessibility

High-contrast color palette

Large, readable fonts

Clear focus states for remote navigation

VoiceOver labels for interactive elements

Testing
Unit Tests

Scoring logic

Fastest-answer bonus logic

Data loading from JSON

Question shuffling

UI Tests

Player setup flow

Question → Reveal navigation

Final leaderboard display

How to Run the Project
Requirements

Xcode 15 or later

tvOS 17+ SDK

Apple TV device or tvOS Simulator

Steps

Clone the repository.

Open TriviaNightTV.xcodeproj in Xcode.

Select the TriviaNightTV tvOS target.

Run on Apple TV Simulator or real Apple TV device.

Assignment Requirement Mapping
Requirement	How It Is Fulfilled
Emerging technology	SwiftUI, tvOS Focus Engine
Multi-screen navigation	Full game flow from setup to leaderboard
Data handling	JSON-based question loading and shuffling
Advanced interaction	Remote-based answering, animations
UI/UX	Kid-friendly, animated, high contrast
Persistent design principles	Structured MVVM architecture
Real-world applicability	Educational trivia for children
Testing	Includes unit and UI tests
License

This project is intended solely for educational and academic purposes as part of the coursework.
