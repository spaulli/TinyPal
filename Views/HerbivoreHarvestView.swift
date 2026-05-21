import SwiftUI

struct HerbivoreHarvestView: View {
    @Bindable var pet: PetModel
    @Environment(\.dismiss) var dismiss
    
    @State private var collectedBerries = 0
    @State private var fallingItems: [FallingItem] = []
    @State private var gameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var showWinCelebration = false
    
    // Animation States
    @State private var petRotation: Double = 0.0
    @State private var petScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Forest Background
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.1), .black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // Falling Berries and Leaves
            ForEach(fallingItems) { item in
                Text(item.isBerry ? "🍓" : "🍃")
                    .font(.system(size: 24))
                    .position(x: item.x, y: item.y)
                    .onTapGesture {
                        if item.isBerry {
                            collectBerry(id: item.id)
                        }
                    }
            }
            
            // Pip (At the bottom, looking up)
            VStack {
                Spacer()
                PetView(
                    petType: "Pip",
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
                .offset(y: 20)
            }
            
            // Score Overlay
            VStack {
                Text("Berries: \(collectedBerries)/4")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                Spacer()
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
        .onReceive(gameTimer) { _ in
            updateGame()
        }
    }
    
    private func updateGame() {
        guard !showWinCelebration else { return }
        
        // Spawn items
        if Double.random(in: 0...1) < 0.1 {
            let newItem = FallingItem(
                x: CGFloat.random(in: 20...160),
                y: -20,
                isBerry: Double.random(in: 0...1) < 0.3,
                speed: CGFloat.random(in: 2...5)
            )
            fallingItems.append(newItem)
        }
        
        // Move items
        for i in 0..<fallingItems.count {
            fallingItems[i].y += fallingItems[i].speed
        }
        
        // Remove off-screen items
        fallingItems.removeAll { $0.y > 200 }
    }
    
    private func collectBerry(id: UUID) {
        guard !showWinCelebration else { return }
        
        if let index = fallingItems.firstIndex(withID: id) {
            fallingItems.remove(at: index)
            collectedBerries += 1
            
            pet.happiness = min(100, pet.happiness + 10)
            
            if collectedBerries >= 4 {
                triggerWin()
            }
        }
    }
    
    private func triggerWin() {
        showWinCelebration = true
        withAnimation(.interpolatingSpring(stiffness: 50, damping: 5).repeatForever()) {
            petRotation = 10
            petScale = 1.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            dismiss()
        }
    }
}

struct FallingItem: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let isBerry: Bool
    let speed: CGFloat
}

extension Array where Element: Identifiable {
    func firstIndex(withID id: Element.ID) -> Int? {
        return firstIndex(where: { $0.id == id })
    }
}
