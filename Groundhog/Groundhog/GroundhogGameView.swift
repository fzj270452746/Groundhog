
import SwiftUI

/// Main game view where the gameplay happens
struct GroundhogGameView: View {
    let gameMode: GroundhogGameMode
    
    @StateObject private var groundhogGameManager = GroundhogGameManager()
    @Environment(\.presentationMode) var groundhogPresentationMode
    @State private var groundhogShowingPauseMenu = false
    @State private var groundhogShowingGameOver = false
    @State private var groundhogAnimateScore = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.2, blue: 0.05),
                        Color(red: 0.1, green: 0.3, blue: 0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: groundhogSpacing(for: geometry)) {
                    // Game Header
                    GroundhogGameHeaderView(
                        gameManager: groundhogGameManager,
                        geometry: geometry,
                        onPause: {
                            groundhogGameManager.groundhogPauseGame()
                            groundhogShowingPauseMenu = true
                        },
                        onQuit: {
                            groundhogGameManager.groundhogEndGame()
                            groundhogPresentationMode.wrappedValue.dismiss()
                        }
                    )
                    .padding(.horizontal, groundhogPadding(for: geometry))
                    .padding(.top, 8)
                    
                    // Game Instructions
                    if groundhogGameManager.groundhogGameState == .ready {
                        VStack(spacing: 8) {
                            Text("Find matching pairs!")
                                .font(.system(size: groundhogInstructionSize(for: geometry), weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                            
                            Text("Tap cards to reveal them")
                                .font(.system(size: groundhogInstructionSize(for: geometry) - 4, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Top Cards Grid
                    if !groundhogGameManager.groundhogTopCards.isEmpty {
                        VStack(spacing: 8) {
                            Text("Top Cards")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            
                            GroundhogCardGridView(
                                cards: groundhogGameManager.groundhogTopCards,
                                geometry: geometry,
                                showBacks: true,
                                allowRotation: true, // Allow rotation for system cards
                                gameManager: groundhogGameManager,
                                onCardTap: { card in
                                    // Top cards are not directly tappable by player
                                    // They are controlled by the game sequence
                                }
                            )
                        }
                    }
                    
                    // Bottom Cards Grid
                    if !groundhogGameManager.groundhogBottomCards.isEmpty {
                        VStack(spacing: 8) {
                            Text("Bottom Cards")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            
                            GroundhogCardGridView(
                                cards: groundhogGameManager.groundhogBottomCards,
                                geometry: geometry,
                                showBacks: false,
                                allowRotation: false, // Disable rotation for player cards
                                gameManager: groundhogGameManager,
                                onCardTap: { card in
                                    groundhogGameManager.groundhogHandleCardTap(card)
                                    groundhogTriggerScoreAnimation()
                                }
                            )
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            groundhogGameManager.groundhogStartGame(mode: gameMode)
        }
        .onChange(of: groundhogGameManager.groundhogGameState) { state in
            if state == .finished {
                groundhogShowingGameOver = true
            }
        }
        .sheet(isPresented: $groundhogShowingPauseMenu) {
            GroundhogPauseMenuView(
                gameManager: groundhogGameManager,
                onResume: {
                    groundhogShowingPauseMenu = false
                    groundhogGameManager.groundhogResumeGame()
                },
                onRestart: {
                    groundhogShowingPauseMenu = false
                    groundhogGameManager.groundhogStartGame(mode: gameMode)
                },
                onHome: {
                    groundhogShowingPauseMenu = false
                    groundhogGameManager.groundhogEndGame()
                    groundhogPresentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func groundhogTriggerScoreAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            groundhogAnimateScore = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                groundhogAnimateScore = false
            }
        }
    }
    
    // MARK: - Layout Helpers
    
    private func groundhogSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.02
    }
    
    private func groundhogPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.04
    }
    
    private func groundhogInstructionSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 18
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
}

// MARK: - Game Header

struct GroundhogGameHeaderView: View {
    @ObservedObject var gameManager: GroundhogGameManager
    let geometry: GeometryProxy
    let onPause: () -> Void
    let onQuit: () -> Void
    
    var body: some View {
        HStack {
            // Score
            VStack(alignment: .leading, spacing: 4) {
                Text("Score")
                    .font(.system(size: groundhogLabelSize, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(gameManager.groundhogStats.groundhogCurrentScore)")
                    .font(.system(size: groundhogValueSize, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            }
            
            Spacer()
            
            // Timer (for timed mode)
            if gameManager.groundhogGameMode == .timed {
                VStack(alignment: .center, spacing: 4) {
                    Text("Time")
                        .font(.system(size: groundhogLabelSize, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(groundhogFormattedTime)
                        .font(.system(size: groundhogValueSize, weight: .bold, design: .rounded))
                        .foregroundColor(gameManager.groundhogStats.groundhogTimeRemaining < 30 ? .red : .white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                }
            }
            
            Spacer()
            
            // Control buttons
            HStack(spacing: 12) {
                GroundhogControlButton(
                    icon: "pause.fill",
                    geometry: geometry,
                    action: onPause
                )
                
                GroundhogControlButton(
                    icon: "xmark",
                    geometry: geometry,
                    action: onQuit
                )
            }
        }
    }
    
    private var groundhogFormattedTime: String {
        let minutes = Int(gameManager.groundhogStats.groundhogTimeRemaining) / 60
        let seconds = Int(gameManager.groundhogStats.groundhogTimeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var groundhogLabelSize: CGFloat {
        let baseSize: CGFloat = 14
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogValueSize: CGFloat {
        let baseSize: CGFloat = 24
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
}

// MARK: - Control Button

struct GroundhogControlButton: View {
    let icon: String
    let geometry: GeometryProxy
    let action: () -> Void
    
    @State private var groundhogIsPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: groundhogIconSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: groundhogButtonSize, height: groundhogButtonSize)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                )
                .scaleEffect(groundhogIsPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: groundhogIsPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            groundhogIsPressed = pressing
        }, perform: {})
    }
    
    private var groundhogIconSize: CGFloat {
        let baseSize: CGFloat = 20
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return max(baseSize * scaleFactor, 12) // Ensure minimum size of 12
    }
    
    private var groundhogButtonSize: CGFloat {
        let baseSize: CGFloat = 44
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return max(baseSize * scaleFactor, 30) // Ensure minimum size of 30
    }
}

// MARK: - Card Grid

struct GroundhogCardGridView: View {
    let cards: [GroundhogCard]
    let geometry: GeometryProxy
    let showBacks: Bool
    let allowRotation: Bool // New parameter to control rotation animations
    @ObservedObject var gameManager: GroundhogGameManager
    let onCardTap: (GroundhogCard) -> Void
    
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: groundhogGridSpacing), count: 4)
    private static let groundhogGridSpacing: CGFloat = 8
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: Self.groundhogGridSpacing) {
            ForEach(cards) { card in
                GroundhogCardView(
                    card: card,
                    showBack: showBacks && !card.groundhogIsFlipped,
                    geometry: geometry,
                    animation: gameManager.groundhogCardAnimations[card.id] ?? .none,
                    allowRotation: allowRotation,
                    onTap: {
                        onCardTap(card)
                    }
                )
            }
        }
        .padding(groundhogGridPadding(for: geometry))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private func groundhogGridPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.02
    }
}

// MARK: - Individual Card

struct GroundhogCardView: View {
    let card: GroundhogCard
    let showBack: Bool
    let geometry: GeometryProxy
    let animation: GroundhogCardAnimation
    let allowRotation: Bool
    let onTap: () -> Void
    
    @State private var groundhogIsPressed = false
    
    var body: some View {
        Button(action: onTap) {
            Group {
                if showBack {
                    Image(card.groundhogBackImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(card.groundhogImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(width: groundhogCardSize, height: groundhogCardSize)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(groundhogBorderColor, lineWidth: groundhogBorderWidth)
            )
            .scaleEffect(groundhogScaleEffect)
            .rotationEffect(groundhogRotationEffect)
            .animation(.easeInOut(duration: 0.3), value: animation)
            .animation(.easeInOut(duration: 0.1), value: groundhogIsPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            groundhogIsPressed = pressing
        }, perform: {})
    }
    
    private var groundhogCardSize: CGFloat {
        let availableWidth = geometry.size.width - 80 // Account for padding and spacing
        let cardWidth = availableWidth / 4 - 8 // 4 cards per row minus spacing
        return max(min(cardWidth, 60), 30) // Ensure minimum size of 30 and maximum of 60
    }
    
    private var groundhogScaleEffect: CGFloat {
        if groundhogIsPressed {
            return 0.95
        }
        
        switch animation {
        case .correct:
            return 1.1
        case .incorrect:
            return 0.9
        case .flip:
            return 1.05
        default:
            return 1.0
        }
    }
    
    private var groundhogRotationEffect: Angle {
        guard allowRotation else { return .degrees(0) }
        
        switch animation {
        case .flip:
            return .degrees(5)
        default:
            return .degrees(0)
        }
    }
    
    private var groundhogBorderColor: Color {
        switch animation {
        case .correct:
            return .green
        case .incorrect:
            return .red
        case .flip:
            return .yellow
        default:
            return .clear
        }
    }
    
    private var groundhogBorderWidth: CGFloat {
        switch animation {
        case .correct, .incorrect, .flip:
            return 3
        default:
            return 0
        }
    }
}

// MARK: - Preview

#Preview {
    GroundhogGameView(gameMode: .infinite)
}
