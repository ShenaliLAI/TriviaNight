# TriviaNight
MADD Assignment part B

# Trivia Night

A multiplayer trivia game built with SwiftUI for Apple TV (tvOS). One person hosts the game on the TV, and players take turns answering multiple-choice questions. The app tracks individual scores and shows a celebratory results screen at the end of the game.

## Features

- *Apple TV host experience*
- *Lobby screen* to choose 1–4 players and customize player names
- *Multiple-choice questions* loaded from local JSON (questions.json)
- *Per-player turn system* and per-player score tracking
- *Animated UI* with gradients, confetti, and trophy animation
- *Results screen* highlighting the winner(s)

## Tech Stack

- *Language:* Swift
- *UI Framework:* SwiftUI
- *Platform:* tvOS / Apple TV
- *Persistence:* Core Data template (via PersistenceController)

## Project Structure (high level)

- Trivia_LinkApp.swift – App entry point
- ContentView.swift – Main navigation, lobby, questions, and results views
- TriviaManager.swift – Loads questions from JSON, manages current question & score
- TriviaQuestion.swift – Model for each trivia question
- questions.json – Question bank
- MultipeerManager.swift – Multipeer Connectivity plumbing (future extension for connected devices)

## Getting Started

### Requirements

- Xcode (latest stable version)
- A Mac capable of running the required Xcode version
- tvOS simulator or a physical Apple TV device

### Running the App

1. Open Trivia Link.xcodeproj in Xcode.
2. In the scheme selector, choose a *tvOS* target (e.g. Apple TV simulator).
3. Build and run the project (⌘R).
4. On the Apple TV simulator/device:
   - You should see the *TriviaNightTV* home screen.
   - Select *Host New Game* to open the lobby.
   - Set number of players (1–4) and edit names if you like.
   - Start the game and take turns answering questions with the remote.

## Customising Questions

Questions are stored in questions.json as an array of objects. Each question has:

- question: The question text
- options: Array of possible answers (e.g. 4 options)
- correctIndex: The index (0-based) of the correct answer inside options

To customize the trivia content, edit questions.json and rebuild the app.

## Future Improvements / Ideas

- Add companion iOS/iPadOS app as controllers via Multipeer Connectivity
- Add categories and difficulty levels
- Add timers and streak bonuses
- Persist high scores and past game history

## License

This project is for educational use. Add a license here if you plan to open source it (e.g. MIT, Apache 2.0).

