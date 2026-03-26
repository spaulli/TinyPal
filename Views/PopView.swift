import SwiftUI
import WatchKit

struct PopView: View {
    @Bindable var pet: PetModel
    @Environment(\.dismiss) var dismiss
    
    @State private var circles: [CircleItem] = []
    @State private var showWinState = false
    @State private var jumpOffset: CGFloat = 0.0
    @State private var petRotation: Double = 0.0
    
    // Bright Bubble Colors
    let brightColors: [Color] = [.pink, .cyan, .yellow, .orange, .mint]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if showWinState {
                    ConfettiView()
                    
                    // Win State: Jump animation for 3s
                    VStack {
                        PetView(petType: pet.petType, color: pet.bodyColor, isBreathing: false, isSleeping: false, showHappyEyes: true)
                            .rotationEffect(.degrees(petRotation))
                            .offset(y: jumpOffset)
                            .onAppear {
                                triggerSpecialMove()
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Bubbles Setup
                    ForEach($circles) { $circle in
                        if circle.isVisible || circle.isPopping {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [circle.color.opacity(0.8), circle.color.opacity(0.4)]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 25
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .position(circle.position)
                                .offset(y: circle.floatOffset)
                                .scaleEffect(circle.scale)
                                .opacity(circle.opacity)
                                .animation(
                                    Animation.easeInOut(duration: circle.floatDuration)
                                        .repeatForever(autoreverses: true)
                                        .delay(circle.floatDelay),
                                    value: circle.floatOffset
                                )
                                .onTapGesture {
                                    pop(circle: &circle)
                                }
                        }
                    }
                }
                
                // Back Button
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .onAppear {
                generateBubbles(in: geometry.size)
            }
            .onChange(of: circles.filter { $0.isVisible }.count) { _, newCount in
                if newCount == 0 && !circles.isEmpty && !showWinState {
                    triggerWinState()
                }
            }
        }
    }
    
    private func generateBubbles(in size: CGSize) {
        let inset: CGFloat = 30
        var newCircles: [CircleItem] = []
        for _ in 0..<5 {
            newCircles.append(CircleItem(
                position: CGPoint(
                    x: CGFloat.random(in: inset...(max(inset, size.width - inset))),
                    y: CGFloat.random(in: inset...(max(inset, size.height - inset)))
                ),
                color: brightColors.randomElement() ?? .pink,
                floatDuration: Double.random(in: 1.5...2.5),
                floatOffset: CGFloat.random(in: 10...20),
                floatDelay: Double.random(in: 0...2.0)
            ))
        }
        circles = newCircles
        
        // Push initial animation toggle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for i in 0..<circles.count {
                circles[i].floatOffset = -circles[i].floatOffset
            }
        }
    }
    
    private func pop(circle: inout CircleItem) {
        if circle.isPopping { return }
        circle.isPopping = true
        
        // Heavy haptic impact simulation
        WKInterfaceDevice.current().play(.retry)
        AudioManager.shared.playPopSound()
        
        withAnimation(.easeOut(duration: 0.1)) {
            circle.scale = 1.5
            circle.opacity = 0
        }
        
        let id = circle.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let idx = circles.firstIndex(where: { $0.id == id }) {
                circles[idx].isVisible = false
                circles[idx].isPopping = false
            }
        }
        
        pet.play()
    }
    
    private func triggerSpecialMove() {
        let move = pet.petType
        if move == "Bramble" {
            withAnimation(.interpolatingSpring(stiffness: 50, damping: 5)) {
                petRotation = 360
            }
        } else if move == "Nova" {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4).repeatForever(autoreverses: true)) {
                jumpOffset = -40
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4).repeatForever(autoreverses: true)) {
                jumpOffset = -30
            }
        }
    }
    
    private func triggerWinState() {
        showWinState = true
        WKInterfaceDevice.current().play(.success)
        AudioManager.shared.playGiggleSound()
        
        // Wait 3 seconds to auto-dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            dismiss()
        }
    }
}



struct CircleItem: Identifiable, Equatable {
    let id = UUID()
    var isVisible = true
    var isPopping = false
    var position: CGPoint
    var color: Color
    
    // Animation properties Tracker
    var floatDuration: Double
    var floatOffset: CGFloat
    var floatDelay: Double
    
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
}
