
import Foundation
import SwiftUI

// MARK: - Game Models

/// Game modes available in the app
enum GroundhogGameMode: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case infinite = "Infinite Mode"
    case timed = "Timed Mode"
    
    var groundhogDescription: String {
        switch self {
        case .infinite:
            return "Play endlessly until you quit. Score accumulates over time."
        case .timed:
            return "Race against time! 120 seconds to achieve your best score."
        }
    }
    
    var groundhogIcon: String {
        switch self {
        case .infinite:
            return "infinity"
        case .timed:
            return "timer"
        }
    }
}

/// Game states during gameplay
enum GroundhogGameState {
    case ready
    case playing
    case paused
    case finished
}

/// Card suit types
enum GroundhogCardSuit: String, CaseIterable {
    case circle = "circle"
    case zi = "zi"
    case bamboo = "bamboo"
    case special = "speceal"
    
    var groundhogRange: ClosedRange<Int> {
        switch self {
        case .circle, .zi, .bamboo:
            return 1...9
        case .special:
            return 1...7
        }
    }
}

/// Individual card model
struct GroundhogCard: Identifiable, Equatable, Hashable {
    let id = UUID()
    let groundhogSuit: GroundhogCardSuit
    let groundhogValue: Int
    var groundhogIsFlipped: Bool = false
    var groundhogIsMatched: Bool = false
    var groundhogPosition: GroundhogGridPosition = GroundhogGridPosition(row: 0, col: 0)
    
    var groundhogImageName: String {
        return "Groundhog-\(groundhogSuit.rawValue)-\(groundhogValue)"
    }
    
    var groundhogBackImageName: String {
        return "Groundhog-Cover"
    }
    
    static func == (lhs: GroundhogCard, rhs: GroundhogCard) -> Bool {
        return lhs.groundhogSuit == rhs.groundhogSuit && lhs.groundhogValue == rhs.groundhogValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(groundhogSuit)
        hasher.combine(groundhogValue)
    }
}

/// Grid position for cards
struct GroundhogGridPosition: Equatable {
    let row: Int
    let col: Int
}

/// Game score record
struct GroundhogScoreRecord: Identifiable, Codable {
    let id = UUID()
    let groundhogScore: Int
    let groundhogMode: String
    let groundhogDate: Date
    let groundhogDuration: TimeInterval?
    
    var groundhogFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: groundhogDate)
    }
    
    var groundhogFormattedDuration: String {
        guard let duration = groundhogDuration else { return "N/A" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

/// Game statistics
struct GroundhogGameStats {
    var groundhogCurrentScore: Int = 0
    var groundhogTimeRemaining: TimeInterval = 120
    var groundhogCorrectMatches: Int = 0
    var groundhogIncorrectMatches: Int = 0
    var groundhogTotalAttempts: Int = 0
    
    var groundhogAccuracy: Double {
        guard groundhogTotalAttempts > 0 else { return 0 }
        return Double(groundhogCorrectMatches) / Double(groundhogTotalAttempts) * 100
    }
    
    mutating func groundhogResetStats() {
        groundhogCurrentScore = 0
        groundhogTimeRemaining = 120
        groundhogCorrectMatches = 0
        groundhogIncorrectMatches = 0
        groundhogTotalAttempts = 0
    }
}

/// Animation states for cards
enum GroundhogCardAnimation {
    case none
    case flip
    case correct
    case incorrect
    case appear
    case disappear
}

/// Sound effects enum
enum GroundhogSoundEffect: String {
    case cardFlip = "card_flip"
    case correctMatch = "correct_match"
    case incorrectMatch = "incorrect_match"
    case gameStart = "game_start"
    case gameEnd = "game_end"
    case buttonTap = "button_tap"
}
