import SwiftUI
import WatchKit

struct PeekABooView: View {
    @Bindable var pet: PetModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isHidden = true
    @State private var showStars = false
    @State private var lastInteractionDate = Date()
    @State private var timer: Timer? = nil
    
    // Animation States
    @State private var armRotation: CGFloat = 160 // Aggressive hide
    @State private var scale: CGFloat = 0.8 // Slightly smaller for watch fit
    @State private var petRotation: Double = 0
    @State private var starOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background Room Consistent with main view
            Color(white: 0.12).edgesIgnoringSafeArea(.all)
            
            // Background Window & Floor
            GeometryReader { geo in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        WindowView(condition: pet.currentCondition)
                            .frame(width: 80, height: 80)
                            .padding(.trailing, 20)
                            .padding(.bottom, 60)
                    }
                    Spacer()
                }
            }.allowsHitTesting(false)
            
            GeometryReader { geo in
                VStack {
                    Spacer()
                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color(white: 0.25)]), startPoint: .top, endPoint: .bottom)
                        .frame(height: geo.size.height * 0.2)
                }
            }.edgesIgnoringSafeArea(.bottom).allowsHitTesting(false)
            
            // The Character: Bramble (Centered)
            ZStack {
                // Bramble Base
                BearShape(
                    color: pet.bodyColor,
                    isBreathing: isHidden,
                    armSweep: armRotation,
                    legSweep: 0
                )
                .scaleEffect(scale)
                .rotationEffect(.degrees(petRotation))
                .overlay(
                    // Custom Eye/Face Overlay for the game
                    ZStack {
                        if isHidden {
                            // "n" curves for closed eyes - Locked to head position
                            HStack(spacing: 20) {
                                EyeCurve()
                                    .stroke(Color.black, lineWidth: 3)
                                    .frame(width: 14, height: 8)
                                EyeCurve()
                                    .stroke(Color.black, lineWidth: 3)
                                    .frame(width: 14, height: 8)
                            }
                            .offset(y: -42)
                        } else {
                            // Large Happy Eyes and D-Smile
                            VStack(spacing: 4) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle().fill(Color.black).frame(width: 16, height: 16)
                                        Circle().fill(Color.white).frame(width: 5, height: 5).offset(x: 4, y: -4)
                                    }
                                    ZStack {
                                        Circle().fill(Color.black).frame(width: 16, height: 16)
                                        Circle().fill(Color.white).frame(width: 5, height: 5).offset(x: 4, y: -4)
                                    }
                                }
                                
                                // Big D-Smile on muzzle
                                DSmile()
                                    .fill(Color.black)
                                    .frame(width: 25, height: 12)
                                    .padding(.top, 4)
                            }
                            .offset(y: -38)
                        }
                    }
                )
                
                // Stars Explosion
                if showStars {
                    StarsBurst()
                        .opacity(starOpacity)
                        .offset(y: -40)
                }
            }
            .onTapGesture {
                revealBramble()
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
        }
        .onAppear {
            startMuffledGiggleLoop()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func revealBramble() {
        guard isHidden else { return }
        
        isHidden = false
        WKInterfaceDevice.current().play(.success)
        AudioManager.shared.playPeekabooSound()
        
        // Rapid Reveal Animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            armRotation = -20 // Snapped down
            scale = 1.0 // Pop to full size
            starOpacity = 1.0
            showStars = true
        }
        
        // Happiness Boost
        pet.happiness = min(100, pet.happiness + 15)
        
        // Reset Logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            hideBramble()
        }
        
        // Hide stars
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 1.0)) {
                starOpacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showStars = false
            }
        }
    }
    
    private func hideBramble() {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
            isHidden = true
            armRotation = 160 // Aggressive hide
            scale = 0.8
        }
        startMuffledGiggleLoop()
    }
    
    private func startMuffledGiggleLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            if isHidden {
                AudioManager.shared.playMuffledGiggle()
            }
        }
    }
}

struct EyeCurve: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY), radius: rect.width / 2, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        return path
    }
}

struct DSmile: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.minY), radius: rect.width / 2, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct StarsBurst: View {
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                Text("⭐")
                    .font(.system(size: 14))
                    .offset(x: CGFloat.random(in: -60...60), y: CGFloat.random(in: -60...60))
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
            }
        }
    }
}
