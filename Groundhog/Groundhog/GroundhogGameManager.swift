
import Foundation
import SwiftUI
import Combine

/// Main game manager that handles all game logic
class GroundhogGameManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var groundhogGameState: GroundhogGameState = .ready
    @Published var groundhogGameMode: GroundhogGameMode = .infinite
    @Published var groundhogStats: GroundhogGameStats = GroundhogGameStats()
    @Published var groundhogTopCards: [GroundhogCard] = []
    @Published var groundhogBottomCards: [GroundhogCard] = []
    @Published var groundhogCurrentFlippedCard: GroundhogCard?
    @Published var groundhogShowingCard: Bool = false
    @Published var groundhogCardAnimations: [UUID: GroundhogCardAnimation] = [:]
    
    // MARK: - Private Properties
    private var groundhogTimer: Timer?
    private var groundhogCardTimer: Timer?
    private var groundhogAllCards: [GroundhogCard] = []
    private var groundhogStartTime: Date?
    
    // MARK: - Constants
    private let groundhogGridSize = 4
    private let groundhogScoreIncrement = 5
    private let groundhogTimedModeDuration: TimeInterval = 120
    private let groundhogCardDisplayDuration: TimeInterval = 2.0
    
    // Dynamic difficulty constants
    private let groundhogInitialMinInterval: TimeInterval = 1.0  // Starting minimum interval
    private let groundhogInitialMaxInterval: TimeInterval = 3.0  // Starting maximum interval
    private let groundhogFinalMinInterval: TimeInterval = 0.3    // Fastest minimum interval
    private let groundhogFinalMaxInterval: TimeInterval = 1.0    // Fastest maximum interval
    private let groundhogMaxDifficultyScore = 200                // Score at which difficulty caps out
    
    init() {
        groundhogGenerateCards()
    }
    
    // MARK: - Public Methods
    
    /// Start a new game
    func groundhogStartGame(mode: GroundhogGameMode) {
        groundhogGameMode = mode
        groundhogGameState = .playing
        groundhogStats.groundhogResetStats()
        groundhogStartTime = Date()
        
        if mode == .timed {
            groundhogStats.groundhogTimeRemaining = groundhogTimedModeDuration
            groundhogStartTimer()
        }
        
        groundhogGenerateCards()
        groundhogShuffleCards()
        groundhogStartCardSequence()
    }
    
    /// Pause the current game
    func groundhogPauseGame() {
        guard groundhogGameState == .playing else { return }
        groundhogGameState = .paused
        groundhogStopTimers()
    }
    
    /// Resume the paused game
    func groundhogResumeGame() {
        guard groundhogGameState == .paused else { return }
        groundhogGameState = .playing
        
        if groundhogGameMode == .timed {
            groundhogStartTimer()
        }
        groundhogStartCardSequence()
    }
    
    /// End the current game
    func groundhogEndGame() {
        groundhogGameState = .finished
        groundhogStopTimers()
        
        // Save score if greater than 0
        if groundhogStats.groundhogCurrentScore > 0 {
            groundhogSaveScore()
        }
    }
    
    /// Handle card tap in bottom grid
    func groundhogHandleCardTap(_ card: GroundhogCard) {
        guard groundhogGameState == .playing,
              let flippedCard = groundhogCurrentFlippedCard else { return }
        
        groundhogStats.groundhogTotalAttempts += 1
        
        if card == flippedCard {
            // Correct match
            groundhogStats.groundhogCorrectMatches += 1
            groundhogStats.groundhogCurrentScore += groundhogScoreIncrement
            groundhogSetCardAnimation(card.id, .correct)
            groundhogFlipCardBack(flippedCard)
        } else {
            // Incorrect match
            groundhogStats.groundhogIncorrectMatches += 1
            groundhogStats.groundhogCurrentScore = max(0, groundhogStats.groundhogCurrentScore - groundhogScoreIncrement)
            groundhogSetCardAnimation(card.id, .incorrect)
        }
        
        // Clear animations after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.groundhogClearCardAnimation(card.id)
        }
    }
    
    /// Reset game to initial state
    func groundhogResetGame() {
        groundhogGameState = .ready
        groundhogStats.groundhogResetStats()
        groundhogCurrentFlippedCard = nil
        groundhogShowingCard = false
        groundhogStopTimers()
        groundhogCardAnimations.removeAll()
        groundhogGenerateCards()
    }
    
    // MARK: - Private Methods
    
    /// Generate all 34 cards
    private func groundhogGenerateCards() {
        groundhogAllCards.removeAll()
        
        // Generate regular suits (circle, zi, bamboo) - 1 to 9 each
        for suit in [GroundhogCardSuit.circle, .zi, .bamboo] {
            for value in suit.groundhogRange {
                groundhogAllCards.append(GroundhogCard(groundhogSuit: suit, groundhogValue: value))
            }
        }
        
        // Generate special cards - 1 to 7
        for value in GroundhogCardSuit.special.groundhogRange {
            groundhogAllCards.append(GroundhogCard(groundhogSuit: .special, groundhogValue: value))
        }
        
        // Select 16 random cards for the game
        let selectedCards = Array(groundhogAllCards.shuffled().prefix(16))
        groundhogTopCards = selectedCards
        groundhogBottomCards = selectedCards
    }
    
    /// Shuffle card positions
    private func groundhogShuffleCards() {
        groundhogTopCards.shuffle()
        groundhogBottomCards.shuffle()
        
        // Assign grid positions
        for (index, _) in groundhogTopCards.enumerated() {
            let row = index / groundhogGridSize
            let col = index % groundhogGridSize
            groundhogTopCards[index].groundhogPosition = GroundhogGridPosition(row: row, col: col)
        }
        
        for (index, _) in groundhogBottomCards.enumerated() {
            let row = index / groundhogGridSize
            let col = index % groundhogGridSize
            groundhogBottomCards[index].groundhogPosition = GroundhogGridPosition(row: row, col: col)
        }
    }
    
    /// Start the card showing sequence
    private func groundhogStartCardSequence() {
        guard groundhogGameState == .playing else { return }
        
        let (minInterval, maxInterval) = groundhogCalculateDynamicIntervals()
        let randomInterval = TimeInterval.random(in: minInterval...maxInterval)
        
        groundhogCardTimer = Timer.scheduledTimer(withTimeInterval: randomInterval, repeats: false) { _ in
            self.groundhogShowRandomCard()
        }
    }
    
    /// Show a random card from top grid
    private func groundhogShowRandomCard() {
        guard groundhogGameState == .playing else { return }
        
        // Hide current card if showing
        if let currentCard = groundhogCurrentFlippedCard {
            groundhogFlipCardBack(currentCard)
        }
        
        // Show new random card
        let randomCard = groundhogTopCards.randomElement()!
        groundhogFlipCard(randomCard)
        
        // Schedule next card
        groundhogStartCardSequence()
    }
    
    /// Flip a card to show its face
    private func groundhogFlipCard(_ card: GroundhogCard) {
        if let index = groundhogTopCards.firstIndex(where: { $0.id == card.id }) {
            groundhogTopCards[index].groundhogIsFlipped = true
            groundhogCurrentFlippedCard = groundhogTopCards[index]
            groundhogShowingCard = true
            groundhogSetCardAnimation(card.id, .flip)
            
            // Auto flip back after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + groundhogCardDisplayDuration) {
                if self.groundhogCurrentFlippedCard?.id == card.id {
                    self.groundhogFlipCardBack(card)
                }
            }
        }
    }
    
    /// Flip a card back to show its back
    private func groundhogFlipCardBack(_ card: GroundhogCard) {
        if let index = groundhogTopCards.firstIndex(where: { $0.id == card.id }) {
            groundhogTopCards[index].groundhogIsFlipped = false
            groundhogCurrentFlippedCard = nil
            groundhogShowingCard = false
            groundhogSetCardAnimation(card.id, .flip)
            
            // Clear flip animation after a short delay to return to normal state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.groundhogClearCardAnimation(card.id)
            }
        }
    }
    
    /// Start the game timer for timed mode
    private func groundhogStartTimer() {
        groundhogTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.groundhogStats.groundhogTimeRemaining > 0 {
                self.groundhogStats.groundhogTimeRemaining -= 1
            } else {
                self.groundhogEndGame()
            }
        }
    }
    
    /// Stop all timers
    private func groundhogStopTimers() {
        groundhogTimer?.invalidate()
        groundhogTimer = nil
        groundhogCardTimer?.invalidate()
        groundhogCardTimer = nil
    }
    
    /// Calculate dynamic card flip intervals based on current score
    /// Returns (minInterval, maxInterval) tuple that decreases linearly with score
    private func groundhogCalculateDynamicIntervals() -> (TimeInterval, TimeInterval) {
        let currentScore = groundhogStats.groundhogCurrentScore
        
        // Ensure score is non-negative for calculation
        let scoreForCalculation = max(0, currentScore)
        
        // Calculate difficulty progress (0.0 to 1.0)
        let difficultyProgress = min(1.0, Double(scoreForCalculation) / Double(groundhogMaxDifficultyScore))
        
        // Linear interpolation from initial to final intervals
        let minInterval = groundhogInitialMinInterval - (groundhogInitialMinInterval - groundhogFinalMinInterval) * difficultyProgress
        let maxInterval = groundhogInitialMaxInterval - (groundhogInitialMaxInterval - groundhogFinalMaxInterval) * difficultyProgress
        
        return (minInterval, maxInterval)
    }
    
    /// Set animation for a specific card
    private func groundhogSetCardAnimation(_ cardId: UUID, _ animation: GroundhogCardAnimation) {
        withAnimation(.easeInOut(duration: 0.3)) {
            groundhogCardAnimations[cardId] = animation
        }
    }
    
    /// Clear animation for a specific card
    private func groundhogClearCardAnimation(_ cardId: UUID) {
        withAnimation(.easeInOut(duration: 0.3)) {
            groundhogCardAnimations[cardId] = GroundhogCardAnimation.none
        }
    }
    
    /// Save the current score to leaderboard
    private func groundhogSaveScore() {
        let duration = groundhogStartTime != nil ? Date().timeIntervalSince(groundhogStartTime!) : nil
        let record = GroundhogScoreRecord(
            groundhogScore: groundhogStats.groundhogCurrentScore,
            groundhogMode: groundhogGameMode.rawValue,
            groundhogDate: Date(),
            groundhogDuration: duration
        )
        GroundhogLeaderboardManager.shared.groundhogAddScore(record)
    }
}

// MARK: - Leaderboard Manager

/// Manages leaderboard data persistence
class GroundhogLeaderboardManager: ObservableObject {
    static let shared = GroundhogLeaderboardManager()
    
    @Published var groundhogScores: [GroundhogScoreRecord] = []
    
    private let groundhogUserDefaults = UserDefaults.standard
    private let groundhogScoresKey = "GroundhogScores"
    
    init() {
        groundhogLoadScores()
    }
    
    /// Add a new score to the leaderboard
    func groundhogAddScore(_ record: GroundhogScoreRecord) {
        groundhogScores.append(record)
        groundhogScores.sort { $0.groundhogScore > $1.groundhogScore }
        
        // Keep only top 100 scores
        if groundhogScores.count > 100 {
            groundhogScores = Array(groundhogScores.prefix(100))
        }
        
        groundhogSaveScores()
    }
    
    /// Get top scores for a specific mode
    func groundhogGetTopScores(for mode: GroundhogGameMode, limit: Int = 10) -> [GroundhogScoreRecord] {
        return groundhogScores
            .filter { $0.groundhogMode == mode.rawValue }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Clear all scores
    func groundhogClearAllScores() {
        groundhogScores.removeAll()
        groundhogSaveScores()
    }
    
    // MARK: - Private Methods
    
    private func groundhogSaveScores() {
        if let encoded = try? JSONEncoder().encode(groundhogScores) {
            groundhogUserDefaults.set(encoded, forKey: groundhogScoresKey)
        }
    }
    
    private func groundhogLoadScores() {
        if let data = groundhogUserDefaults.data(forKey: groundhogScoresKey),
           let decoded = try? JSONDecoder().decode([GroundhogScoreRecord].self, from: data) {
            groundhogScores = decoded
        }
    }
}
