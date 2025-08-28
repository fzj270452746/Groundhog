
import SwiftUI

/// Leaderboard view showing high scores
struct GroundhogLeaderboardView: View {
    @StateObject private var groundhogLeaderboard = GroundhogLeaderboardManager.shared
    @Environment(\.presentationMode) var groundhogPresentationMode
    @State private var groundhogSelectedMode: GroundhogGameMode = .infinite
    @State private var groundhogShowingClearAlert = false
    @State private var groundhogAnimateRows = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    // Background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.1, green: 0.3, blue: 0.1),
                            Color(red: 0.2, green: 0.5, blue: 0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: groundhogSpacing(for: geometry)) {
                        // Mode selector
                        GroundhogModeSelector(
                            selectedMode: $groundhogSelectedMode,
                            geometry: geometry
                        )
                        
                        // Scores list
                        if groundhogFilteredScores.isEmpty {
                            GroundhogEmptyStateView(geometry: geometry)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(Array(groundhogFilteredScores.enumerated()), id: \.element.id) { index, score in
                                        GroundhogScoreRowView(
                                            score: score,
                                            rank: index + 1,
                                            geometry: geometry
                                        )
                                        .scaleEffect(groundhogAnimateRows ? 1.0 : 0.8)
                                        .opacity(groundhogAnimateRows ? 1.0 : 0.0)
                                        .animation(
                                            .spring(response: 0.6, dampingFraction: 0.8)
                                                .delay(Double(index) * 0.05),
                                            value: groundhogAnimateRows
                                        )
                                    }
                                }
                                .padding(.horizontal, groundhogPadding(for: geometry))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, groundhogTopPadding(for: geometry))
                }
                .navigationTitle("Leaderboard")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(
                    leading: Button("Close") {
                        groundhogPresentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white),
                    trailing: Menu {
                        Button(action: {
                            groundhogShowingClearAlert = true
                        }) {
                            Label("Clear All Scores", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                groundhogAnimateRows = true
            }
        }
        .onChange(of: groundhogSelectedMode) { _ in
            groundhogAnimateRows = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                groundhogAnimateRows = true
            }
        }
        .alert(isPresented: $groundhogShowingClearAlert) {
            Alert(
                title: Text("Clear All Scores"),
                message: Text("This action cannot be undone. All scores will be permanently deleted."),
                primaryButton: .destructive(Text("Clear")) {
                    groundhogLeaderboard.groundhogClearAllScores()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var groundhogFilteredScores: [GroundhogScoreRecord] {
        groundhogLeaderboard.groundhogGetTopScores(for: groundhogSelectedMode, limit: 50)
    }
    
    // MARK: - Layout Helpers
    
    private func groundhogSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.02
    }
    
    private func groundhogPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.05
    }
    
    private func groundhogTopPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.01
    }
}

// MARK: - Mode Selector

struct GroundhogModeSelector: View {
    @Binding var selectedMode: GroundhogGameMode
    let geometry: GeometryProxy
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(GroundhogGameMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMode = mode
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: mode.groundhogIcon)
                            .font(.system(size: groundhogIconSize, weight: .semibold))
                            .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.6))
                        
                        Text(mode.rawValue)
                            .font(.system(size: groundhogTextSize, weight: .medium, design: .rounded))
                            .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedMode == mode ? Color.white.opacity(0.2) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, groundhogHorizontalPadding)
    }
    
    private var groundhogIconSize: CGFloat {
        let baseSize: CGFloat = 20
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogTextSize: CGFloat {
        let baseSize: CGFloat = 14
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogHorizontalPadding: CGFloat {
        return geometry.size.width * 0.05
    }
}

// MARK: - Score Row

struct GroundhogScoreRowView: View {
    let score: GroundhogScoreRecord
    let rank: Int
    let geometry: GeometryProxy
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(groundhogRankColor)
                    .frame(width: groundhogRankSize, height: groundhogRankSize)
                
                Text("\(rank)")
                    .font(.system(size: groundhogRankTextSize, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Score info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(score.groundhogScore)")
                        .font(.system(size: groundhogScoreTextSize, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(score.groundhogFormattedDate)
                        .font(.system(size: groundhogDateTextSize, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                if score.groundhogDuration != nil {
                    Text("Duration: \(score.groundhogFormattedDuration)")
                        .font(.system(size: groundhogDetailTextSize, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Medal for top 3
            if rank <= 3 {
                Image(systemName: groundhogMedalIcon)
                    .font(.system(size: groundhogMedalSize, weight: .semibold))
                    .foregroundColor(groundhogMedalColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var groundhogRankColor: Color {
        switch rank {
        case 1:
            return .yellow
        case 2:
            return Color(red: 0.8, green: 0.8, blue: 0.8) // Silver
        case 3:
            return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default:
            return Color(red: 0.3, green: 0.6, blue: 0.3)
        }
    }
    
    private var groundhogMedalIcon: String {
        switch rank {
        case 1:
            return "medal.fill"
        case 2:
            return "medal.fill"
        case 3:
            return "medal.fill"
        default:
            return ""
        }
    }
    
    private var groundhogMedalColor: Color {
        switch rank {
        case 1:
            return .yellow
        case 2:
            return Color(red: 0.8, green: 0.8, blue: 0.8)
        case 3:
            return Color(red: 0.8, green: 0.5, blue: 0.2)
        default:
            return .clear
        }
    }
    
    // MARK: - Size Helpers
    
    private var groundhogRankSize: CGFloat {
        let baseSize: CGFloat = 40
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogRankTextSize: CGFloat {
        let baseSize: CGFloat = 16
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogScoreTextSize: CGFloat {
        let baseSize: CGFloat = 20
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogDateTextSize: CGFloat {
        let baseSize: CGFloat = 12
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogDetailTextSize: CGFloat {
        let baseSize: CGFloat = 11
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogMedalSize: CGFloat {
        let baseSize: CGFloat = 24
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
}

// MARK: - Empty State

struct GroundhogEmptyStateView: View {
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: groundhogSpacing(for: geometry)) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: groundhogIconSize(for: geometry), weight: .light))
                .foregroundColor(.white.opacity(0.6))
            
            Text("No Scores Yet")
                .font(.system(size: groundhogTitleSize(for: geometry), weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Play some games to see your scores here!")
                .font(.system(size: groundhogSubtitleSize(for: geometry), weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(groundhogPadding(for: geometry))
        .frame(maxWidth: .infinity)
    }
    
    private func groundhogIconSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 80
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogTitleSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 24
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogSubtitleSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 16
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.02
    }
    
    private func groundhogPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.1
    }
}

// MARK: - Preview

#Preview {
    GroundhogLeaderboardView()
}
