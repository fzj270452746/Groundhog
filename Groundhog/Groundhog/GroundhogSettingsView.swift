

import SwiftUI
import MessageUI

/// Settings view with game instructions and feedback options
struct GroundhogSettingsView: View {
    @Environment(\.presentationMode) var groundhogPresentationMode
    @State private var groundhogShowingInstructions = false
    @State private var groundhogShowingFeedback = false
    @State private var groundhogShowingAbout = false
    @State private var groundhogAnimateItems = false
    
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
                    
                    ScrollView {
                        VStack(spacing: groundhogSpacing(for: geometry)) {
                            // Header
                            VStack(spacing: 12) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: groundhogHeaderIconSize(for: geometry), weight: .light))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("Settings")
                                    .font(.system(size: groundhogHeaderTextSize(for: geometry), weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, groundhogTopPadding(for: geometry))
                            .scaleEffect(groundhogAnimateItems ? 1.0 : 0.8)
                            .opacity(groundhogAnimateItems ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: groundhogAnimateItems)
                            
                            // Settings items
                            VStack(spacing: 16) {
                                GroundhogSettingsItem(
                                    title: "How to Play",
                                    subtitle: "Learn the game rules and controls",
                                    icon: "questionmark.circle.fill",
                                    color: .blue,
                                    geometry: geometry
                                ) {
                                    groundhogShowingInstructions = true
                                }
                                .scaleEffect(groundhogAnimateItems ? 1.0 : 0.5)
                                .opacity(groundhogAnimateItems ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: groundhogAnimateItems)
                                
                                GroundhogSettingsItem(
                                    title: "Send Feedback",
                                    subtitle: "Report bugs or suggest improvements",
                                    icon: "envelope.fill",
                                    color: .orange,
                                    geometry: geometry
                                ) {
                                    groundhogShowingFeedback = true
                                }
                                .scaleEffect(groundhogAnimateItems ? 1.0 : 0.5)
                                .opacity(groundhogAnimateItems ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: groundhogAnimateItems)
                                
                                GroundhogSettingsItem(
                                    title: "About",
                                    subtitle: "App version and developer info",
                                    icon: "info.circle.fill",
                                    color: .purple,
                                    geometry: geometry
                                ) {
                                    groundhogShowingAbout = true
                                }
                                .scaleEffect(groundhogAnimateItems ? 1.0 : 0.5)
                                .opacity(groundhogAnimateItems ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: groundhogAnimateItems)
                            }
                            .padding(.horizontal, groundhogPadding(for: geometry))
                            
                            Spacer(minLength: groundhogBottomSpacing(for: geometry))
                        }
                    }
                }
                .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            // Close button overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        groundhogPresentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: groundhogCloseButtonSize(for: geometry), weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                            )
                    }
                    .padding(.trailing, groundhogPadding(for: geometry))
                    .padding(.top, groundhogTopPadding(for: geometry))
                }
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                groundhogAnimateItems = true
            }
        }
        .sheet(isPresented: $groundhogShowingInstructions) {
            GroundhogInstructionsView()
        }
        .sheet(isPresented: $groundhogShowingFeedback) {
            GroundhogFeedbackView()
        }
        .sheet(isPresented: $groundhogShowingAbout) {
            GroundhogAboutView()
        }
    }
    
    // MARK: - Layout Helpers
    
    private func groundhogHeaderIconSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 60
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogHeaderTextSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 32
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogCloseButtonSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 30
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.04
    }
    
    private func groundhogPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.05
    }
    
    private func groundhogTopPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.05
    }
    
    private func groundhogBottomSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.1
    }
}

// MARK: - Settings Item

struct GroundhogSettingsItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let geometry: GeometryProxy
    let action: () -> Void
    
    @State private var groundhogIsPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: groundhogIconBackgroundSize, height: groundhogIconBackgroundSize)
                    
                    Image(systemName: icon)
                        .font(.system(size: groundhogIconSize, weight: .semibold))
                        .foregroundColor(color)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: groundhogTitleSize, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.system(size: groundhogSubtitleSize, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
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
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(groundhogIsPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: groundhogIsPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            groundhogIsPressed = pressing
        }, perform: {})
    }
    
    private var groundhogIconBackgroundSize: CGFloat {
        let baseSize: CGFloat = 50
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogIconSize: CGFloat {
        let baseSize: CGFloat = 24
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogTitleSize: CGFloat {
        let baseSize: CGFloat = 18
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogSubtitleSize: CGFloat {
        let baseSize: CGFloat = 14
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
}

// MARK: - Instructions View

struct GroundhogInstructionsView: View {
    @Environment(\.presentationMode) var groundhogPresentationMode
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.1, green: 0.3, blue: 0.1),
                            Color(red: 0.2, green: 0.5, blue: 0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: groundhogSpacing(for: geometry)) {
                            GroundhogInstructionSection(
                                title: "Game Overview",
                                content: "Mahjong Groundhog is a memory and reaction game based on traditional Mahjong tiles. Test your memory and reflexes in two exciting game modes!",
                                geometry: geometry
                            )
                            
                            GroundhogInstructionSection(
                                title: "How to Play",
                                content: """
                                1. The game shows two 4×4 grids of cards
                                2. Top grid shows card backs (some will flip to reveal tiles)
                                3. Bottom grid shows all tile faces in different positions
                                4. When a card flips in the top grid, quickly tap the matching tile in the bottom grid
                                5. Correct matches earn +5 points, wrong matches lose 5 points (minimum 0)
                                """,
                                geometry: geometry
                            )
                            
                            GroundhogInstructionSection(
                                title: "Infinite Mode",
                                content: "Play endlessly with no time limit. Cards will randomly flip at regular intervals. Your score accumulates as long as you keep playing. Perfect for relaxed practice sessions.",
                                geometry: geometry
                            )
                            
                            GroundhogInstructionSection(
                                title: "Timed Mode",
                                content: "Race against the clock! You have exactly 120 seconds to score as many points as possible. The pressure is on - can you maintain accuracy under time pressure?",
                                geometry: geometry
                            )
                            
                            GroundhogInstructionSection(
                                title: "Scoring",
                                content: "• Correct match: +5 points\n• Wrong match: -5 points\n• Minimum score: 0 points\n• Only positive scores are saved to the leaderboard",
                                geometry: geometry
                            )
                            
                            GroundhogInstructionSection(
                                title: "Tips for Success",
                                content: "• Study the bottom grid layout before starting\n• Focus on the flipped card and scan quickly\n• Don't panic - accuracy is more important than speed\n• Practice in Infinite Mode to improve your skills",
                                geometry: geometry
                            )
                        }
                        .padding(groundhogPadding(for: geometry))
                    }
                }
                .navigationTitle("How to Play")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(
                    trailing: Button("Done") {
                        groundhogPresentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private func groundhogSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.025
    }
    
    private func groundhogPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.05
    }
}

struct GroundhogInstructionSection: View {
    let title: String
    let content: String
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: groundhogTitleSize, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
            
            Text(content)
                .font(.system(size: groundhogContentSize, weight: .medium))
                .foregroundColor(.white)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var groundhogTitleSize: CGFloat {
        let baseSize: CGFloat = 20
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private var groundhogContentSize: CGFloat {
        let baseSize: CGFloat = 16
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
}

// MARK: - Feedback View

struct GroundhogFeedbackView: View {
    @Environment(\.presentationMode) var groundhogPresentationMode
    @State private var groundhogFeedbackText = ""
    @State private var groundhogShowingMailAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
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
                        VStack(alignment: .leading, spacing: 12) {
                            Text("We'd love to hear from you!")
                                .font(.system(size: groundhogTitleSize(for: geometry), weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Your feedback helps us improve the game. Report bugs, suggest features, or just let us know what you think.")
                                .font(.system(size: groundhogSubtitleSize(for: geometry), weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(2)
                        }
                        
                        VStack(spacing: 16) {
                            TextEditor(text: $groundhogFeedbackText)
                                .font(.system(size: groundhogTextSize(for: geometry)))
                                .padding(12)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .frame(minHeight: groundhogTextEditorHeight(for: geometry))
                            
                            Button(action: groundhogSendFeedback) {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Text("Send Feedback")
                                        .font(.system(size: groundhogButtonTextSize(for: geometry), weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.blue.opacity(0.8),
                                                    Color.blue.opacity(0.6)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                            }
                            .disabled(groundhogFeedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .opacity(groundhogFeedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                        }
                        
                        Spacer()
                    }
                    .padding(groundhogPadding(for: geometry))
                }
                .navigationTitle("Send Feedback")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(
                    trailing: Button("Cancel") {
                        groundhogPresentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .alert(isPresented: $groundhogShowingMailAlert) {
            Alert(
                title: Text("Mail Not Available"),
                message: Text("Please set up Mail app or contact us directly at feedback@groundhog.com"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func groundhogSendFeedback() {
        // In a real app, you would implement email functionality here
        // For now, we'll just show an alert
        groundhogShowingMailAlert = true
    }
    
    // MARK: - Layout Helpers
    
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
    
    private func groundhogTextSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 16
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogButtonTextSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 18
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogTextEditorHeight(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.25
    }
    
    private func groundhogSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.03
    }
    
    private func groundhogPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.05
    }
}

// MARK: - About View

struct GroundhogAboutView: View {
    @Environment(\.presentationMode) var groundhogPresentationMode
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
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
                        // App icon and name
                        VStack(spacing: 16) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: groundhogIconSize(for: geometry), weight: .light))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 8) {
                                Text("Mahjong Groundhog")
                                    .font(.system(size: groundhogTitleSize(for: geometry), weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Version 1.0.0")
                                    .font(.system(size: groundhogVersionSize(for: geometry), weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About This Game")
                                .font(.system(size: groundhogSectionSize(for: geometry), weight: .semibold, design: .rounded))
                                .foregroundColor(.yellow)
                            
                            Text("A fun and challenging memory game inspired by traditional Mahjong tiles. Test your reflexes and memory skills in two exciting game modes!")
                                .font(.system(size: groundhogContentSize(for: geometry), weight: .medium))
                                .foregroundColor(.white)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )

                        
                        Spacer()
                        
                        // Copyright
                        Text("© 2025 Mahjong Groundhog. All rights reserved.")
                            .font(.system(size: groundhogCopyrightSize(for: geometry), weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(groundhogPadding(for: geometry))
                }
                .navigationTitle("About")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(
                    trailing: Button("Done") {
                        groundhogPresentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    // MARK: - Layout Helpers
    
    private func groundhogIconSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 80
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogTitleSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 28
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogVersionSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 18
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogSectionSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 20
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogContentSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 16
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogCopyrightSize(for geometry: GeometryProxy) -> CGFloat {
        let baseSize: CGFloat = 12
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 667)
        return baseSize * scaleFactor
    }
    
    private func groundhogSpacing(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.height * 0.03
    }
    
    private func groundhogPadding(for geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width * 0.05
    }
}

// MARK: - Preview

#Preview {
    GroundhogSettingsView()
}
