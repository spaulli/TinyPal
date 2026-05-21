import SwiftUI

struct CosyCaveView: View {
    @Bindable var pet: PetModel
    @Environment(\.dismiss) var dismiss
    
    @State private var stokeCount = 0
    @State private var isGlowActive = false
    @State private var fireParticles: [FireParticle] = []
    @State private var lastStokeDate = Date()
    @State private var showWinCelebration = false
    
    // Animation States
    @State private var petScale: CGFloat = 1.0
    @State private var petRotation: Double = 0.0
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Dark Cave Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Dynamic Radial Warmth Overlay
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.27, blue: 0.0).opacity(Double(stokeCount) * 0.12),
                    Color.clear
                ]),
                center: UnitPoint(x: 0.65, y: 0.85),
                startRadius: 0,
                endRadius: CGFloat(stokeCount) * 30
            )
            .edgesIgnoringSafeArea(.all)
            .animation(.easeInOut(duration: 0.8), value: stokeCount)
            
            // Bramble (Centered, transitions to dance)
            VStack {
                Spacer()
                PetView(
                    petType: "Bramble",
                    color: pet.bodyColor,
                    isBreathing: true,
                    isSleeping: false,
                    showHappyEyes: showWinCelebration,
                    mood: .happy,
                    scaleY: petScale,
                    scaleX: petScale
                )
                .rotationEffect(.degrees(petRotation))
                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: showWinCelebration)
                .offset(y: -20)
                Spacer()
            }
            
            // The Campfire (65% Right)
            GeometryReader { geo in
                ZStack {
                    // Logs (Static Teepee)
                    TeepeeLogsView()
                        .frame(width: 80, height: 60)
                        .scaleEffect(isGlowActive ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.8), value: isGlowActive)
                    
                    // Dynamic Fire (SVG Path equivalent)
                    FireVisualView(stokeCount: stokeCount)
                        .frame(width: 60, height: 60)
                        .offset(y: -15)
                }
                .position(x: geo.size.width * 0.65, y: geo.size.height * 0.85)
                .onTapGesture {
                    stokeFire()
                }
            }
            
            // UI Overlay
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .padding()
                    Spacer()
                }
                Spacer()
            }
            
            // Confetti Overlay
            if showWinCelebration {
                ConfettiView()
            }
        }
        .onReceive(timer) { _ in
            checkDecay()
        }
    }
    
    private func stokeFire() {
        guard isGlowActive && !showWinCelebration else { return }
        
        AudioManager.shared.playCrackleSound()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            stokeCount = min(7, stokeCount + 1)
            isGlowActive = false
            lastStokeDate = Date()
        }
        
        pet.happiness = min(100, pet.happiness + 8)
        
        if stokeCount >= 7 {
            triggerWin()
        }
    }
    
    private func checkDecay() {
        guard stokeCount > 0 && !showWinCelebration else { return }
        
        let secondsSinceStoke = Date().timeIntervalSince(lastStokeDate)
        if secondsSinceStoke >= 5.0 {
            withAnimation {
                stokeCount = max(0, stokeCount - 1)
                lastStokeDate = Date() // Reset to prevent rapid triple decay
            }
        }
        
        // Handle log interaction pulse (similar to 1.5s interval in JS)
        if !isGlowActive && !showWinCelebration {
            withAnimation(.easeInOut(duration: 0.8)) {
                isGlowActive = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                if !showWinCelebration { isGlowActive = false }
            }
        }
    }
    
    private func triggerWin() {
        showWinCelebration = true
        withAnimation(.interpolatingSpring(stiffness: 50, damping: 5).repeatForever()) {
            petRotation = 360
            petScale = 1.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            dismiss()
        }
    }
}

// MARK: - Components

struct TeepeeLogsView: View {
    var body: some View {
        ZStack {
            // Logs
            Rectangle()
                .fill(Color(red: 0.4, green: 0.2, blue: 0.1))
                .frame(width: 40, height: 10)
                .rotationEffect(.degrees(-30))
                .offset(x: -15, y: 10)
            Rectangle()
                .fill(Color(red: 0.4, green: 0.2, blue: 0.1))
                .frame(width: 40, height: 10)
                .rotationEffect(.degrees(30))
                .offset(x: 15, y: 10)
            Rectangle()
                .fill(Color(red: 0.47, green: 0.2, blue: 0.1))
                .frame(width: 40, height: 10)
                .offset(y: 15)
        }
    }
}

struct FireVisualView: View {
    var stokeCount: Int
    var body: some View {
        ZStack {
            // Base Core (Always visible)
            FlamePath()
                .fill(Color.orange)
                .opacity(0.8)
                .scaleEffect(0.6)
            
            // Dynamic Layers
            ForEach(0..<stokeCount, id: \.self) { i in
                FlamePath()
                    .fill(i % 2 == 0 ? Color.orange : Color.yellow)
                    .opacity(0.8)
                    .scaleEffect(0.6 + (Double(i) * 0.1))
                    .offset(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5))
            }
        }
        .blur(radius: 2)
    }
}

struct FlamePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.midY))
        return path
    }
}

struct FireParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
}
