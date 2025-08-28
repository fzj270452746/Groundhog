
import SwiftUI

// MARK: - Pause Menu

struct GroundhogPauseMenuView: View {
    @ObservedObject var gameManager: GroundhogGameManager
    let onResume: () -> Void
    let onRestart: () -> Void
    let onHome: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background blur effect
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                // Menu content
                VStack(spacing: groundhogSpacing(for: geometry)) {
                    // Title
                    Text("Game Paused")
                        .font(.system(size: groundhogTitleSize(for: geometry), weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                    
                    // Stats
                    VStack(spacing: 12) {
                        GroundhogStatRow(
                            label: "Current Score",
                            value: "\(gameManager.groundhogStats.groundhogCurrentScore)",
                            geometry: geometry
                        )
                        
                        GroundhogStatRow(
                            label: "Correct Matches",
                            value: "\(gameManager.groundhogStats.groundhogCorrectMatches)",
                            geometry: geometry
                        )
                        
                        GroundhogStatRow(
                            label: "Accuracy",
                            value: String(format: "%.1f%%", gameManager.groundhogStats.groundhogAccuracy),
                            geometry: geometry
                        )
                        
                        if gameManager.groundhogGameMode == .timed {
                            GroundhogStatRow(
                                label: "Time Remaining",
                                value: groundhogFormattedTime,
                                geometry: geometry
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                    )
                    
                    // Menu buttons
                    VStack(spacing: 16) {
                        GroundhogMenuButton(
                            title: "Resume",
                            icon: "play.fill",
                            color: .green,
                            geometry: geometry,
                            action: onResume
                        )
                        
                        GroundhogMenuButton(
                            title: "Restart",
                            icon: "arrow.clockwise",
                            color: .orange,
                            geometry: geometry,
                            action: onRestart
                        )
                        
                        GroundhogMenuButton(
                            title: "Home",
                            icon: "house.fill",
                            color: .red,
                            geometry: geometry,
                            action: onHome
                        )
                    }
                }
                .padding(groundhogPadding(for: geometry))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.1, green: 0.3, blue: 0.1),
                                    Color(red: 0.2, green: 0.5, blue: 0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                )
                .frame(maxWidth: groundhogMaxWidth(for: geometry))
            }
        }
    }
    
    private var groundhogFormattedTime: String {
        let minutes = Int(gameManager.groundhogStats.groundhogTimeRemaining) / 60
        let seconds = Int(gameManager.groundhogStats.groundhogTimeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Layout Helpers
    
    private func groundhogTitleSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 28
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.03
    }
    
    private func groundhogPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.08
    }
    
    private func groundhogMaxWidth(for geometry: GeometryProxy) -> CGFloat {
        return min(geometry.size.width * 0.9, 400)
    }
}

// MARK: - Game Over View

struct GroundhogGameOverView: View {
    @ObservedObject var gameManager: GroundhogGameManager
    let geometry: GeometryProxy
    let onRestart: () -> Void
    let onHome: () -> Void
    
    @State private var groundhogShowingDetails = false
    @State private var groundhogAnimateScore = false
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: groundhogSpacing(for: geometry)) {
                // Game Over Title
                Text("Game Over!")
                    .font(.system(size: groundhogTitleSize(for: geometry), weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                
                // Final Score
                VStack(spacing: 8) {
                    Text("Final Score")
                        .font(.system(size: groundhogSubtitleSize(for: geometry), weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(gameManager.groundhogStats.groundhogCurrentScore)")
                        .font(.system(size: groundhogScoreSize(for: geometry), weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                        .scaleEffect(groundhogAnimateScore ? 1.2 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: groundhogAnimateScore)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                )
                
                // Performance message
                Text(groundhogPerformanceMessage)
                    .font(.system(size: groundhogMessageSize(for: geometry), weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Detailed stats (expandable)
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            groundhogShowingDetails.toggle()
                        }
                    }) {
                        HStack {
                            Text("View Details")
                                .font(.system(size: groundhogDetailSize(for: geometry), weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            
                            Image(systemName: groundhogShowingDetails ? "chevron.up" : "chevron.down")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    if groundhogShowingDetails {
                        VStack(spacing: 8) {
                            GroundhogStatRow(
                                label: "Correct Matches",
                                value: "\(gameManager.groundhogStats.groundhogCorrectMatches)",
                                geometry: geometry
                            )
                            
                            GroundhogStatRow(
                                label: "Incorrect Matches",
                                value: "\(gameManager.groundhogStats.groundhogIncorrectMatches)",
                                geometry: geometry
                            )
                            
                            GroundhogStatRow(
                                label: "Total Attempts",
                                value: "\(gameManager.groundhogStats.groundhogTotalAttempts)",
                                geometry: geometry
                            )
                            
                            GroundhogStatRow(
                                label: "Accuracy",
                                value: String(format: "%.1f%%", gameManager.groundhogStats.groundhogAccuracy),
                                geometry: geometry
                            )
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.2))
                )
                
                // Action buttons
                VStack(spacing: 12) {
                    GroundhogMenuButton(
                        title: "Play Again",
                        icon: "arrow.clockwise",
                        color: .green,
                        geometry: geometry,
                        action: onRestart
                    )
                    
                    GroundhogMenuButton(
                        title: "Home",
                        icon: "house.fill",
                        color: .blue,
                        geometry: geometry,
                        action: onHome
                    )
                }
            }
            .padding(groundhogPadding(for: geometry))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.3, blue: 0.1),
                                Color(red: 0.2, green: 0.5, blue: 0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .frame(maxWidth: groundhogMaxWidth(for: geometry))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                groundhogAnimateScore = true
            }
        }
    }
    
    private var groundhogPerformanceMessage: String {
        let score = gameManager.groundhogStats.groundhogCurrentScore
        let accuracy = gameManager.groundhogStats.groundhogAccuracy
        
        if score == 0 {
            return "Better luck next time! Keep practicing to improve your skills."
        } else if score < 50 {
            return "Good start! You're getting the hang of it."
        } else if score < 100 {
            return "Nice work! You're becoming quite skilled."
        } else if accuracy > 80 {
            return "Excellent performance! Your accuracy is outstanding."
        } else {
            return "Amazing score! You're a Mahjong Groundhog master!"
        }
    }
    
    // MARK: - Layout Helpers
    
    private func groundhogTitleSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 32
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogSubtitleSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 18
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogScoreSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 48
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogMessageSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 16
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogDetailSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 16
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.025
    }
    
    private func groundhogPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.08
    }
    
    private func groundhogMaxWidth(for geometry: GeometryProxy) -> CGFloat {
        return min(geometry.size.width * 0.9, 400)
    }
}

// MARK: - Reusable Components

struct GroundhogMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let geometry: GeometryProxy
    let action: () -> Void
    
    @State private var groundhogIsPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: groundhogIconSize, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: groundhogTextSize, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.8),
                                color.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(groundhogIsPressed ? 0.95 : 1.0)
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
        return baseSize * scaleFactor
    }
    
    private var groundhogTextSize: CGFloat {
        let baseSize: CGFloat = 18
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
}

struct GroundhogStatRow: View {
    let label: String
    let value: String
    let geometry: GeometryProxy
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: groundhogLabelSize, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: groundhogValueSize, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    private var groundhogLabelSize: CGFloat {
        let baseSize: CGFloat = 16
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogValueSize: CGFloat {
        let baseSize: CGFloat = 16
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
}

