

import SwiftUI

/// Main home screen of the app
struct GroundhogHomeView: View {
    @StateObject private var groundhogGameManager = GroundhogGameManager()
    @StateObject private var groundhogLeaderboard = GroundhogLeaderboardManager.shared
    @State private var groundhogShowingLeaderboard = false
    @State private var groundhogShowingSettings = false
    @State private var groundhogSelectedGameMode: GroundhogGameMode?
    @State private var groundhogAnimateTitle = false
    @State private var groundhogAnimateButtons = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.3, blue: 0.1),
                        Color(red: 0.2, green: 0.5, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Background pattern
                GroundhogBackgroundPatternView()
                    .opacity(0.1)
                
                VStack(spacing: groundhogSpacing(for: geometry)) {
                    Spacer()
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("Mahjong")
                            .font(.system(size: groundhogTitleSize(for: geometry), weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                            .scaleEffect(groundhogAnimateTitle ? 1.0 : 0.8)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: groundhogAnimateTitle)
                        
                        Text("Groundhog")
                            .font(.system(size: groundhogSubtitleSize(for: geometry), weight: .semibold, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                            .scaleEffect(groundhogAnimateTitle ? 1.0 : 0.8)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: groundhogAnimateTitle)
                    }
                    
                    Spacer()
                    
                    // Game mode buttons
                    VStack(spacing: groundhogButtonSpacing(for: geometry)) {
                        ForEach(GroundhogGameMode.allCases, id: \.self) { mode in
                            GroundhogGameModeButton(
                                mode: mode,
                                geometry: geometry
                            ) {
                                groundhogStartGame(mode: mode)
                            }
                            .scaleEffect(groundhogAnimateButtons ? 1.0 : 0.5)
                            .opacity(groundhogAnimateButtons ? 1.0 : 0.0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(GroundhogGameMode.allCases.firstIndex(of: mode) ?? 0) * 0.1 + 0.4),
                                value: groundhogAnimateButtons
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom buttons
                    HStack(spacing: groundhogBottomButtonSpacing(for: geometry)) {
                        GroundhogBottomButton(
                            title: "Leaderboard",
                            icon: "list.number",
                            geometry: geometry
                        ) {
                            groundhogShowingLeaderboard = true
                        }
                        
                        GroundhogBottomButton(
                            title: "Settings",
                            icon: "gearshape.fill",
                            geometry: geometry
                        ) {
                            groundhogShowingSettings = true
                        }
                    }
                    .scaleEffect(groundhogAnimateButtons ? 1.0 : 0.5)
                    .opacity(groundhogAnimateButtons ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: groundhogAnimateButtons)
                    
                    Spacer()
                }
                .padding(groundhogPadding(for: geometry))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            groundhogStartAnimations()
        }
        .sheet(isPresented: $groundhogShowingLeaderboard) {
            GroundhogLeaderboardView()
        }
        .sheet(isPresented: $groundhogShowingSettings) {
            GroundhogSettingsView()
        }
        .fullScreenCover(item: $groundhogSelectedGameMode) { mode in
            GroundhogGameView(gameMode: mode)
        }
    }
    
    // MARK: - Private Methods
    
    private func groundhogStartGame(mode: GroundhogGameMode) {
        groundhogSelectedGameMode = mode
    }
    
    private func groundhogStartAnimations() {
        withAnimation {
            groundhogAnimateTitle = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                groundhogAnimateButtons = true
            }
        }
    }
    
    // MARK: - Layout Helpers
    
    private func groundhogTitleSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 48
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogSubtitleSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 32
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.03
    }
    
    private func groundhogButtonSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.025
    }
    
    private func groundhogBottomButtonSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.1
    }
    
    private func groundhogPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.05
    }
}

// MARK: - Game Mode Button

struct GroundhogGameModeButton: View {
    let mode: GroundhogGameMode
    let geometry: GeometryProxy
    let action: () -> Void
    
    @State private var groundhogIsPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: mode.groundhogIcon)
                    .font(.system(size: groundhogIconSize, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: groundhogTitleSize, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(mode.groundhogDescription)
                        .font(.system(size: groundhogDescriptionSize, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.3, green: 0.6, blue: 0.3),
                                Color(red: 0.2, green: 0.5, blue: 0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
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
        let baseSize: CGFloat = 24
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogTitleSize: CGFloat {
        let baseSize: CGFloat = 20
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogDescriptionSize: CGFloat {
        let baseSize: CGFloat = 14
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
}

// MARK: - Bottom Button

struct GroundhogBottomButton: View {
    let title: String
    let icon: String
    let geometry: GeometryProxy
    let action: () -> Void
    
    @State private var groundhogIsPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: groundhogIconSize, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: groundhogTextSize, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: groundhogButtonWidth, height: groundhogButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.4, green: 0.7, blue: 0.4),
                                Color(red: 0.3, green: 0.6, blue: 0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
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
        let baseSize: CGFloat = 24
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogTextSize: CGFloat {
        let baseSize: CGFloat = 14
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogButtonWidth: CGFloat {
        return geometry.size.width * 0.35
    }
    
    private var groundhogButtonHeight: CGFloat {
        return geometry.size.height * 0.1
    }
}

// MARK: - Background Pattern

struct GroundhogBackgroundPatternView: View {
    var body: some View {
        if #available(iOS 15.0, *) {
            Canvas { context, size in
                let tileSize: CGFloat = 40
                let rows = Int(size.height / tileSize) + 1
                let cols = Int(size.width / tileSize) + 1
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * tileSize
                        let y = CGFloat(row) * tileSize
                        
                        let rect = CGRect(x: x, y: y, width: tileSize, height: tileSize)
                        let path = Path(roundedRect: rect, cornerRadius: 4)
                        
                        context.stroke(path, with: .color(.white.opacity(0.1)), lineWidth: 1)
                    }
                }
            }
        } else {
            // iOS 14 fallback - simple pattern using Rectangle views
            GeometryReader { geometry in
                let tileSize: CGFloat = 40
                let cols = Int(geometry.size.width / tileSize) + 1
                let rows = Int(geometry.size.height / tileSize) + 1
                
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<cols, id: \.self) { col in
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .frame(width: tileSize, height: tileSize)
                            .position(
                                x: CGFloat(col) * tileSize + tileSize/2,
                                y: CGFloat(row) * tileSize + tileSize/2
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GroundhogHomeView()
}
