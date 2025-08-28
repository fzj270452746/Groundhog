

import SwiftUI

// MARK: - Custom Animation Extensions

extension Animation {
    static var groundhogBounce: Animation {
        Animation.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
    }
    
    static var groundhogGentle: Animation {
        Animation.easeInOut(duration: 0.4)
    }
    
    static var groundhogQuick: Animation {
        Animation.easeInOut(duration: 0.2)
    }
    
    static var groundhogSlow: Animation {
        Animation.easeInOut(duration: 0.8)
    }
}

// MARK: - Particle Effect View

struct GroundhogParticleEffect: View {
    @State private var groundhogParticles: [GroundhogParticle] = []
    @State private var groundhogAnimationTimer: Timer?
    
    let groundhogParticleCount = 20
    let groundhogColors: [Color] = [.yellow, .green, .white, .orange]
    
    var body: some View {
        ZStack {
            ForEach(groundhogParticles) { particle in
                Circle()
                    .fill(particle.groundhogColor)
                    .frame(width: particle.groundhogSize, height: particle.groundhogSize)
                    .position(particle.groundhogPosition)
                    .opacity(particle.groundhogOpacity)
                    .animation(.linear(duration: particle.groundhogLifetime), value: particle.groundhogPosition)
                    .animation(.linear(duration: particle.groundhogLifetime), value: particle.groundhogOpacity)
            }
        }
        .onAppear {
            groundhogStartParticleAnimation()
        }
        .onDisappear {
            groundhogStopParticleAnimation()
        }
    }
    
    private func groundhogStartParticleAnimation() {
        groundhogAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            groundhogCreateParticle()
            groundhogUpdateParticles()
        }
    }
    
    private func groundhogStopParticleAnimation() {
        groundhogAnimationTimer?.invalidate()
        groundhogAnimationTimer = nil
    }
    
    private func groundhogCreateParticle() {
        let particle = GroundhogParticle(
            groundhogPosition: CGPoint(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: UIScreen.main.bounds.height + 20
            ),
            groundhogColor: groundhogColors.randomElement() ?? .white,
            groundhogSize: CGFloat.random(in: 2...6),
            groundhogLifetime: Double.random(in: 2...5),
            groundhogOpacity: Double.random(in: 0.3...0.8)
        )
        
        groundhogParticles.append(particle)
        
        // Animate particle upward
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = groundhogParticles.firstIndex(where: { $0.id == particle.id }) {
                groundhogParticles[index].groundhogPosition = CGPoint(
                    x: particle.groundhogPosition.x + CGFloat.random(in: -50...50),
                    y: -20
                )
                groundhogParticles[index].groundhogOpacity = 0
            }
        }
    }
    
    private func groundhogUpdateParticles() {
        groundhogParticles.removeAll { particle in
            particle.groundhogPosition.y < -50
        }
        
        // Limit particle count
        if groundhogParticles.count > groundhogParticleCount {
            groundhogParticles.removeFirst(groundhogParticles.count - groundhogParticleCount)
        }
    }
}

struct GroundhogParticle: Identifiable {
    let id = UUID()
    var groundhogPosition: CGPoint
    let groundhogColor: Color
    let groundhogSize: CGFloat
    let groundhogLifetime: Double
    var groundhogOpacity: Double
}

// MARK: - Floating Animation Modifier

struct GroundhogFloatingEffect: ViewModifier {
    @State private var groundhogOffset: CGFloat = 0
    
    let groundhogAmplitude: CGFloat
    let groundhogDuration: Double
    
    func body(content: Content) -> some View {
        content
            .offset(y: groundhogOffset)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: groundhogDuration)
                        .repeatForever(autoreverses: true)
                ) {
                    groundhogOffset = groundhogAmplitude
                }
            }
    }
}

extension View {
    func groundhogFloatingEffect(amplitude: CGFloat = 10, duration: Double = 2.0) -> some View {
        modifier(GroundhogFloatingEffect(groundhogAmplitude: amplitude, groundhogDuration: duration))
    }
}

// MARK: - Pulse Animation Modifier

struct GroundhogPulseEffect: ViewModifier {
    @State private var groundhogScale: CGFloat = 1.0
    
    let groundhogMinScale: CGFloat
    let groundhogMaxScale: CGFloat
    let groundhogDuration: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(groundhogScale)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: groundhogDuration)
                        .repeatForever(autoreverses: true)
                ) {
                    groundhogScale = groundhogMaxScale
                }
            }
    }
}

extension View {
    func groundhogPulseEffect(minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05, duration: Double = 1.0) -> some View {
        modifier(GroundhogPulseEffect(groundhogMinScale: minScale, groundhogMaxScale: maxScale, groundhogDuration: duration))
    }
}

// MARK: - Shimmer Effect

struct GroundhogShimmerEffect: ViewModifier {
    @State private var groundhogPhase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.4),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: groundhogPhase)
                .animation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: groundhogPhase
                )
            )
            .onAppear {
                groundhogPhase = 300
            }
    }
}

extension View {
    func groundhogShimmerEffect() -> some View {
        modifier(GroundhogShimmerEffect())
    }
}

// MARK: - Card Flip Animation

struct GroundhogCardFlipEffect: ViewModifier {
    @Binding var groundhogIsFlipped: Bool
    
    let groundhogFrontView: AnyView
    let groundhogBackView: AnyView
    
    @State private var groundhogFlipAngle: Double = 0
    @State private var groundhogShowingFront = true
    
    func body(content: Content) -> some View {
        ZStack {
            if groundhogShowingFront {
                groundhogFrontView
            } else {
                groundhogBackView
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .rotation3DEffect(.degrees(groundhogFlipAngle), axis: (x: 0, y: 1, z: 0))
        .onChange(of: groundhogIsFlipped) { flipped in
            withAnimation(.easeInOut(duration: 0.6)) {
                groundhogFlipAngle = flipped ? 180 : 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                groundhogShowingFront = !flipped
            }
        }
    }
}

// MARK: - Score Pop Animation

struct GroundhogScorePopEffect: ViewModifier {
    @State private var groundhogScale: CGFloat = 1.0
    @State private var groundhogOpacity: Double = 1.0
    @State private var groundhogOffset: CGFloat = 0
    
    let groundhogTrigger: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(groundhogScale)
            .opacity(groundhogOpacity)
            .offset(y: groundhogOffset)
            .onChange(of: groundhogTrigger) { _ in
                groundhogAnimateScorePop()
            }
    }
    
    private func groundhogAnimateScorePop() {
        withAnimation(.easeOut(duration: 0.2)) {
            groundhogScale = 1.3
            groundhogOffset = -10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                groundhogScale = 1.0
                groundhogOffset = 0
            }
        }
    }
}

extension View {
    func groundhogScorePopEffect(trigger: Bool) -> some View {
        modifier(GroundhogScorePopEffect(groundhogTrigger: trigger))
    }
}

// MARK: - Confetti Effect

struct GroundhogConfettiEffect: View {
    @State private var groundhogConfettiPieces: [GroundhogConfettiPiece] = []
    @State private var groundhogIsAnimating = false
    
    let groundhogColors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    
    var body: some View {
        ZStack {
            ForEach(groundhogConfettiPieces) { piece in
                Rectangle()
                    .fill(piece.groundhogColor)
                    .frame(width: piece.groundhogSize.width, height: piece.groundhogSize.height)
                    .position(piece.groundhogPosition)
                    .rotationEffect(.degrees(piece.groundhogRotation))
                    .opacity(piece.groundhogOpacity)
                    .animation(.linear(duration: piece.groundhogFallDuration), value: piece.groundhogPosition)
                    .animation(.linear(duration: piece.groundhogFallDuration), value: piece.groundhogRotation)
                    .animation(.linear(duration: piece.groundhogFallDuration), value: piece.groundhogOpacity)
            }
        }
        .onAppear {
            groundhogCreateConfetti()
        }
    }
    
    private func groundhogCreateConfetti() {
        for _ in 0..<50 {
            let piece = GroundhogConfettiPiece(
                groundhogPosition: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -20
                ),
                groundhogColor: groundhogColors.randomElement() ?? .yellow,
                groundhogSize: CGSize(
                    width: CGFloat.random(in: 4...12),
                    height: CGFloat.random(in: 4...12)
                ),
                groundhogRotation: Double.random(in: 0...360),
                groundhogFallDuration: Double.random(in: 2...4),
                groundhogOpacity: Double.random(in: 0.6...1.0)
            )
            
            groundhogConfettiPieces.append(piece)
            
            // Animate piece falling
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let index = groundhogConfettiPieces.firstIndex(where: { $0.id == piece.id }) {
                    groundhogConfettiPieces[index].groundhogPosition = CGPoint(
                        x: piece.groundhogPosition.x + CGFloat.random(in: -100...100),
                        y: UIScreen.main.bounds.height + 50
                    )
                    groundhogConfettiPieces[index].groundhogRotation += Double.random(in: 360...720)
                    groundhogConfettiPieces[index].groundhogOpacity = 0
                }
            }
        }
        
        // Clean up after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            groundhogConfettiPieces.removeAll()
        }
    }
}

struct GroundhogConfettiPiece: Identifiable {
    let id = UUID()
    var groundhogPosition: CGPoint
    let groundhogColor: Color
    let groundhogSize: CGSize
    var groundhogRotation: Double
    let groundhogFallDuration: Double
    var groundhogOpacity: Double
}
