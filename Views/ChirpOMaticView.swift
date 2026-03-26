import SwiftUI
import WatchKit

struct ChirpOMaticView: View {
    @Bindable var pet: PetModel
    @Environment(\.dismiss) var dismiss
    
    // Animation States
    @State private var tweekOffset = CGSize.zero
    @State private var tweekJumpY: CGFloat = 0
    @State private var beakScale: CGFloat = 1.0
    @State private var timer: Timer? = nil
    @State private var successCount = 0
    @State private var showWinState = false
    
    let tiles = [
        TileInfo(id: 0, color: .red, hex: "#e91e63", x: -45, note: "C"),
        TileInfo(id: 1, color: .blue, hex: "#3498db", x: 0, note: "E"),
        TileInfo(id: 2, color: .yellow, hex: "#f1c40f", x: 45, note: "G")
    ]
    
    var body: some View {
        ZStack {
            // Dark Stage Background
            Color(white: 0.1).edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // The Stage with Tiles
                HStack(spacing: 20) {
                    ForEach(tiles) { tile in
                        MusicTile(tile: tile, isActive: activeTile == tile.id)
                            .onTapGesture {
                                playNote(tile)
                            }
                    }
                }
                .padding(.bottom, 20)
            }
            
            // Tweek character
            VStack {
                Spacer()
                ZStack {
                    // Character rendering
                    ChickShape(color: pet.bodyColor, isBreathing: true)
                        .scaleEffect(showWinState ? 1.2 : 0.8)
                        .overlay(
                            TweekFace(isHappy: activeTile != nil || showWinState, forceOMouth: activeTile != nil || showWinState)
                                .scaleEffect(beakScale * (showWinState ? 1.5 : 1.0))
                                .offset(y: -5)
                        )
                }
                .offset(x: tweekOffset.width, y: tweekOffset.height + tweekJumpY)
                .padding(.bottom, 60)
            }
            
            // Victory Confetti
            if showWinState {
                ConfettiView()
                    .zIndex(10)
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
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            // Ensure Tweek starts with a matching game color (Red or Yellow)
            // We avoid Blue (#3498db) because he starts standing on the middle (Blue) tile.
            let startHexes = ["#e91e63", "#f1c40f"] 
            pet.bodyColorHex = startHexes.randomElement() ?? "#e91e63"
            
            startInactivityTimer()
        }
    }
    
    private func playNote(_ tile: TileInfo) {
        lastTapDate = Date()
        activeTile = tile.id
        
        let isMatch = pet.bodyColorHex == tile.hex
        
        // Hopping Animation (Always happens)
        let jumpDuration = 0.35
        
        // 1. Horizontal Move
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            tweekOffset.width = tile.x
        }
        
        // 2. Vertical Arc (Parabolic)
        withAnimation(.easeOut(duration: jumpDuration / 2)) {
            tweekJumpY = -35
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + jumpDuration / 2) {
            withAnimation(.easeIn(duration: jumpDuration / 2)) {
                tweekJumpY = 0
            }
        }
        
        if isMatch {
            // SUCCESS - Happy stuff
            WKInterfaceDevice.current().play(.success)
            AudioManager.shared.playChirp()
            
            // Beak Scale Animation
            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                beakScale = 1.2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring()) {
                    beakScale = 1.0
                }
            }
            
            // Goal: Change color to a random DIFFERENT game color
            let gameHexes = ["#e91e63", "#3498db", "#f1c40f"]
            let currentHex = pet.bodyColorHex
            let nextHex = gameHexes.filter { $0 != currentHex }.randomElement() ?? gameHexes[0]
            
            // Slight delay for the color change so they see the land first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.easeInOut) {
                    pet.bodyColorHex = nextHex
                }
            }
            
            // Participation Boost
            pet.happiness = min(100, pet.happiness + 5)
            
            // Track Win Condition
            successCount += 1
            if successCount >= 5 {
                triggerWin()
            }
        } else {
            // MISMATCH - Small click haptic only
            WKInterfaceDevice.current().play(.click)
        }
        
        // Tile pulse reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if activeTile == tile.id {
                activeTile = nil
            }
        }
    }
    
    private func triggerWin() {
        showWinState = true
        WKInterfaceDevice.current().play(.success)
        
        // Victory Leaps
        for delay in [0.0, 0.6, 1.2] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.25)) {
                    tweekJumpY = -50
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.easeIn(duration: 0.25)) {
                        tweekJumpY = 0
                    }
                }
            }
        }
        
        // Auto-close or Reset after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            dismiss()
        }
    }
    
    private func startInactivityTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if Date().timeIntervalSince(lastTapDate) > 2.0 && tweekOffset.width != 0 {
                returnToHome()
            }
        }
    }
    
    private func returnToHome() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            tweekOffset.width = 0
        }
    }
}

struct MusicTile: View {
    let tile: TileInfo
    let isActive: Bool
    
    var body: some View {
        Circle()
            .fill(tile.color)
            .frame(width: 35, height: 35)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: isActive ? 4 : 0)
                    .blur(radius: 2)
            )
            .shadow(color: tile.color.opacity(0.8), radius: isActive ? 10 : 4)
            .scaleEffect(isActive ? 1.2 : 1.0)
            .brightness(isActive ? 0.3 : 0)
            .animation(.interactiveSpring(), value: isActive)
    }
}

struct TileInfo: Identifiable {
    let id: Int
    let color: Color
    let hex: String
    let x: CGFloat
    let note: String
}
