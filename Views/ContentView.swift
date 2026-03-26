import SwiftUI
import WatchKit

struct ContentView: View {
    @Bindable var pet: PetModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    @AppStorage("isInitialized") private var isInitialized = true
    @State private var dummyCrownValue: Double = 0.0
    @State private var showPopView = false
    @State private var showPeekabooView = false
    @State private var showChirpOMaticView = false
    
    // MARK: - Animation State
    @State private var petScaleY: CGFloat = 1.0
    @State private var petScaleX: CGFloat = 1.0
    @State private var jumpOffset: CGFloat = 0
    @State private var petRotation: Double = 0
    @State private var xOffset: CGFloat = 0.0
    @State private var isAnimating: Bool = false
    @State private var forceO_Mouth: Bool = false
    @State private var forceSleepyEyes: Bool = false
    @State private var faceBlur: CGFloat = 0.0
    @State private var armSweep: CGFloat = 0.0
    @State private var legSweep: CGFloat = 0.0
    @State private var tailRotation: CGFloat = 0.0
    @State private var neckRotation: CGFloat = 0.0
    @State private var showHappyEyes = false
    
    // Feeding sequence states
    @State private var isFeeding = false
    @State private var foodOffset: CGFloat = -150
    @State private var foodOpacity: Double = 0.0
    
    var isSleeping: Bool {
        return scenePhase == .inactive || scenePhase == .background || isLuminanceReduced || pet.isNapping
    }
    
    var body: some View {
        ZStack {
            // Environment (The Room)
            if !isSleeping {
                Color(white: 0.12).edgesIgnoringSafeArea(.all)
                
                // Window in background
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            // (Legacy WindowView removed)
                        }
                        Spacer()
                    }
                }
                .allowsHitTesting(false)
                
                // FloorView
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        LinearGradient(gradient: Gradient(colors: [Color.clear, Color(white: 0.25)]), startPoint: .top, endPoint: .bottom)
                            .frame(height: geo.size.height * 0.2)
                    }
                }.edgesIgnoringSafeArea(.bottom)
                .allowsHitTesting(false)
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 0) {
                // Top Day/Name Overlay
                VStack(spacing: 2) {
                    if !isSleeping {
                        Button(action: {
                            WKInterfaceDevice.current().play(.click)
                            resetApp()
                        }) {
                            Text(pet.displayName)
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack {
                        Button(action: feedPet) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.green)
                                .frame(width: 50, height: 50)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(isFeeding)
                        
                        Spacer()
                        
                        Button(action: { 
                            if pet.petType == "Bramble" {
                                showPeekabooView = true
                            } else if pet.petType == "Tweek" {
                                showChirpOMaticView = true
                            } else {
                                showPopView = true
                            }
                        }) {
                            let icon: String = {
                                if pet.petType == "Bramble" { return "eyes.inverse" }
                                if pet.petType == "Tweek" { return "music.note" }
                                return "bubbles.and.sparkles"
                            }()
                            
                            let color: Color = {
                                if pet.petType == "Bramble" { return .orange }
                                if pet.petType == "Tweek" { return .purple }
                                return .blue
                            }()

                            Image(systemName: icon)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(color)
                                .frame(width: 50, height: 50)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 4)
                .opacity(isSleeping ? 0 : 1)
                .animation(.easeInOut, value: isSleeping)
                
                Spacer()
                
                // Central Character Layout
                ZStack {
                    if pet.petMood == .happy && !isSleeping {
                        HeartsView()
                            .zIndex(0)
                            .allowsHitTesting(false)
                    }
                    
                    PetCore(pet: pet, isSleeping: isSleeping, showHappyEyes: showHappyEyes, forceO_Mouth: forceO_Mouth, forceSleepyEyes: forceSleepyEyes, faceBlur: faceBlur, armSweep: armSweep, legSweep: legSweep, tailRotation: tailRotation, neckRotation: neckRotation, scaleX: petScaleX, scaleY: petScaleY, hearts: pet.hearts)
                        .modifier(TummyRumbleModifier(isHungry: pet.hearts <= 1 && !isSleeping))
                        .scaleEffect(x: petScaleX, y: petScaleY)
                        .rotationEffect(.degrees(petRotation))
                        .offset(x: xOffset, y: jumpOffset)
                        .frame(width: 140, height: 140)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if pet.petType != "Nova" {
                                WKInterfaceDevice.current().play(.click)
                                triggerRandomAnimation()
                            }
                        }
                        .onLongPressGesture(minimumDuration: 3.0) {
                            if !isSleeping {
                                WKInterfaceDevice.current().play(.success)
                                resetApp()
                            }
                        }
                        .zIndex(1)
                }
                
                Spacer()
                
                // Bottom Controls
                HStack {
                    Button(action: {
                        if !isSleeping {
                            WKInterfaceDevice.current().play(.success)
                            pet.cycleColor()
                        }
                    }) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.purple)
                            .frame(width: 50, height: 50)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .opacity(isSleeping ? 0 : 1)
                .animation(.easeInOut, value: isSleeping)
            }
            .zIndex(1)
            
            // Food Overlay System
            if isFeeding {
                Image(systemName: "applelogo")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .offset(y: foodOffset)
                    .opacity(foodOpacity)
                    .zIndex(2)
            }
        }
        .sheet(isPresented: $showPopView) {
            PopView(pet: pet)
        }
        .sheet(isPresented: $showPeekabooView) {
            PeekABooView(pet: pet)
        }
        .sheet(isPresented: $showChirpOMaticView) {
            ChirpOMaticView(pet: pet)
        }
        .focusable(true)
        .digitalCrownRotation($dummyCrownValue)
        .onAppear {
            pet.updatePetStatus()
        }
    }
    
    private func petPal() {
        if isSleeping { return }
        AudioManager.shared.playGiggleSound()
        pet.pet()
        performLeap()
    }
    
    private func feedPet() {
        guard !isFeeding else { return }
        WKInterfaceDevice.current().play(.click)
        AudioManager.shared.playEatSound()
        
        isFeeding = true
        foodOffset = -150
        foodOpacity = 1.0
        
        withAnimation(.easeIn(duration: 0.5)) {
            foodOffset = 10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pet.feed()
            foodOpacity = 0.0
            showHappyEyes = true
            
            performLeap()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showHappyEyes = false
                isFeeding = false
            }
        }
    }
    
    private func performLeap() {
        WKInterfaceDevice.current().play(.click)
        
        // Squash down (Y down to 0.7)
        withAnimation(.easeOut(duration: 0.15)) {
            petScaleY = 0.7
            petScaleX = 1.3
            jumpOffset = 5
        }
        
        // Stretch up (Y up to 1.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.2)) {
                petScaleY = 1.3
                petScaleX = 0.8
                jumpOffset = -40
            }
            
            // Settle back to 1.0 with a slight spring bounce
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                WKInterfaceDevice.current().play(.success)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    petScaleX = 1.0
                    petScaleY = 1.0
                    jumpOffset = 0
                }
            }
        }
    }
    
    private func triggerRandomAnimation() {
        if pet.hunger <= 0 || isAnimating { return } // Cannot play if asleep/starving
        isAnimating = true
        
        let move = pet.petType
        if move == "Bramble" {
            let anims = ["tummy-pat", "peekaboo", "heavy-tumble", "happy-jive"]
            let choice = anims.randomElement()!
            
            let brambleSpring = Animation.spring(response: 0.8, dampingFraction: 0.6)
            
            switch choice {
            case "tummy-pat":
                withAnimation(brambleSpring) {
                    armSweep = 60
                    petScaleX = 1.05
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(brambleSpring) {
                        petScaleX = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(brambleSpring) {
                            armSweep = 0
                            petScaleX = 1.0
                        }
                        self.isAnimating = false
                    }
                }
            case "peekaboo":
                withAnimation(brambleSpring) {
                    armSweep = -140
                    forceSleepyEyes = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(brambleSpring) {
                        armSweep = 0
                        forceSleepyEyes = false
                        showHappyEyes = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        showHappyEyes = false
                        self.isAnimating = false
                    }
                }
            case "heavy-tumble":
                withAnimation(.easeInOut(duration: 2.0)) {
                    petRotation = 360
                }
                // Squash when half-way (butt touches floor)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(brambleSpring) {
                        petScaleY = 0.7
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(brambleSpring) {
                            petScaleY = 1.0
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                    petRotation = 0
                    self.isAnimating = false
                }
            case "happy-jive":
                withAnimation(brambleSpring.repeatCount(5, autoreverses: true)) {
                    petRotation = 10
                }
                withAnimation(brambleSpring.repeatCount(10, autoreverses: true)) {
                    legSweep = 15
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(brambleSpring) {
                        petRotation = 0
                        legSweep = 0
                    }
                    self.isAnimating = false
                }
            default: break
            }
        } else if move == "Tweek" || move == "Chick" {
            let anims = ["spin-dry", "peck", "flutter", "waddle", "preen", "startle", "flip"]
            let choice = anims.randomElement()!
            
            switch choice {
            case "spin-dry":
                withAnimation(.linear(duration: 0.05).repeatCount(20, autoreverses: true)) { xOffset = 5; armSweep = 45 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut) { xOffset = 0; armSweep = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.isAnimating = false }
                }
            case "peck":
                withAnimation(.easeInOut(duration: 0.15)) { petRotation = 30; forceO_Mouth = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    AudioManager.shared.playClinkSound()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { petRotation = 0; forceO_Mouth = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.isAnimating = false }
                }
            case "flutter":
                withAnimation(.easeOut(duration: 0.2)) { jumpOffset = -10; faceBlur = 4.0 }
                withAnimation(.linear(duration: 0.05).repeatCount(20, autoreverses: true)) { armSweep = 60 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 0.2)) { jumpOffset = 0; faceBlur = 0.0; armSweep = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.isAnimating = false }
                }
            case "waddle":
                withAnimation(.linear(duration: 0.15).repeatCount(8, autoreverses: true)) { petRotation = 10; xOffset = 15 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut) { petRotation = 0; xOffset = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.isAnimating = false }
                }
            case "preen":
                withAnimation(.easeInOut(duration: 0.4)) { petRotation = -15; armSweep = -80; forceSleepyEyes = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.linear(duration: 0.1).repeatCount(6, autoreverses: true)) { armSweep = -60 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeInOut(duration: 0.4)) { petRotation = 0; armSweep = 0; forceSleepyEyes = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.isAnimating = false }
                    }
                }
            case "startle":
                AudioManager.shared.playPopSound()
                withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) { petScaleY = 1.3; petScaleX = 0.8; jumpOffset = -20; armSweep = -90; forceO_Mouth = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { petScaleY = 1.0; petScaleX = 1.0; jumpOffset = 0; armSweep = 0; forceO_Mouth = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { self.isAnimating = false }
                }
            case "flip":
                withAnimation(.easeInOut(duration: 0.5)) { jumpOffset = -50; petRotation = -360 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeIn(duration: 0.3)) { jumpOffset = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { petScaleY = 0.6; petScaleX = 1.3 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { petScaleY = 1.0; petScaleX = 1.0; petRotation = 0 }
                            self.isAnimating = false
                        }
                    }
                }
            default: break
            }
        } else if move == "Pip" {
            let anims = ["tail-wag", "neck-nuzzle", "dino-jump"]
            let choice = anims.randomElement()!
            
            let pipSpring = Animation.spring(response: 0.8, dampingFraction: 0.6)
            
            switch choice {
            case "tail-wag":
                // Slow and deliberate tail wag +/- 10 degrees (body shimmy)
                withAnimation(pipSpring.repeatCount(4, autoreverses: true)) {
                    tailRotation = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(pipSpring) { tailRotation = 0 }
                    self.isAnimating = false
                }
            case "neck-nuzzle":
                // Smooth head/neck tilt toward the screen (leaning in for a pet)
                withAnimation(pipSpring) {
                    neckRotation = -25
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    withAnimation(pipSpring) {
                        neckRotation = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        self.isAnimating = false
                    }
                }
            case "dino-jump":
                // Flatten belly (Scale Y: 0.6), Leap, Stretch neck (Scale Y: 1.4)
                withAnimation(pipSpring) {
                    petScaleY = 0.6
                    petScaleX = 1.3
                    jumpOffset = 5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        jumpOffset = -70
                        petScaleY = 1.4
                        petScaleX = 0.8
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(pipSpring) {
                            jumpOffset = 0
                            petScaleY = 0.8
                            petScaleX = 1.2
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(pipSpring) {
                                petScaleY = 1.0
                                petScaleX = 1.0
                            }
                            self.isAnimating = false
                        }
                    }
                }
            default: break
            }
        } else {
            let anims = ["leap", "roll", "zoom", "peekaboo"]
            let choice = anims.randomElement()!
            
            switch choice {
            case "leap":
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { petScaleY = 0.7; petScaleX = 1.3; jumpOffset = 10 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { petScaleY = 1.3; petScaleX = 0.8; jumpOffset = -40 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) { petScaleY = 1.0; petScaleX = 1.0; jumpOffset = 0 }
                        self.isAnimating = false
                    }
                }
            case "roll":
                withAnimation(.interpolatingSpring(stiffness: 50, damping: 5)) { petRotation = 360 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { petRotation = 0; self.isAnimating = false }
            case "zoom":
                withAnimation(.easeIn(duration: 0.3)) { xOffset = 250 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    xOffset = -250
                    withAnimation(.easeOut(duration: 0.4)) { xOffset = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.isAnimating = false }
                }
            case "peekaboo":
                withAnimation(.interpolatingSpring(stiffness: 60, damping: 6)) { petScaleX = 0.01; petScaleY = 0.01 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.interpolatingSpring(stiffness: 60, damping: 6)) { petScaleX = 1.0; petScaleY = 1.0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.isAnimating = false }
                }
            default: break
            }
        }
        
        AudioManager.shared.playGiggleSound()
        WKInterfaceDevice.current().play(.success)
        pet.happiness = min(100, pet.happiness + 20)
    }
    
    private func resetApp() {
        pet.colorIndex = 0
        pet.happiness = 100
        pet.hunger = 100
        pet.energy = 100
        isInitialized = false
    }
}

// MARK: - Advanced Animation Components
// (Legacy WindowView removed)

struct PetCore: View {
    @Bindable var pet: PetModel
    var isSleeping: Bool
    var showHappyEyes: Bool = false
    var forceO_Mouth: Bool = false
    var forceSleepyEyes: Bool = false
    var faceBlur: CGFloat = 0.0
    var armSweep: CGFloat = 0.0
    var legSweep: CGFloat = 0.0
    var tailRotation: CGFloat = 0.0
    var neckRotation: CGFloat = 0.0
    var scaleX: CGFloat = 1.0
    var scaleY: CGFloat = 1.0
    var hearts: Int = 4
    
    @State private var phase = false
    
    var body: some View {
        ZStack {
            PetView(
                petType: pet.petType,
                color: pet.bodyColor,
                isBreathing: phase,
                isSleeping: isSleeping,
                showHappyEyes: showHappyEyes,
                mood: pet.petMood,
                forceSleepyEyes: forceSleepyEyes,
                forceO_Mouth: forceO_Mouth,
                faceBlur: faceBlur,
                armSweep: armSweep,
                legSweep: legSweep,
                tailRotation: tailRotation,
                neckRotation: neckRotation,
                scaleY: scaleY,
                scaleX: scaleX,
                hearts: hearts
            )
            .colorMultiply(
                (pet.currentCondition == "Rain" || pet.currentCondition == "Drizzle") ?
                Color(red: 0.8, green: 0.9, blue: 1.0) : .white
            )
            
            if isSleeping {
                Text("zzz")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.gray)
                    .offset(x: 40, y: -40)
            }
        }
        .onAppear {
            // "Breathing" idle animation logic
            withAnimation(.easeInOut(duration: isSleeping ? 3.0 : 1.5).repeatForever(autoreverses: true)) {
                phase.toggle()
            }
        }
        .onChange(of: isSleeping) { _, sleeping in
            phase = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: sleeping ? 3.0 : 1.5).repeatForever(autoreverses: true)) {
                    phase = true
                }
            }
        }
    }
}

struct TummyRumbleModifier: ViewModifier {
    let isHungry: Bool
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: isHungry) { _, newValue in
                if newValue {
                    withAnimation(.linear(duration: 0.1).repeatForever(autoreverses: true)) { offset = -3 }
                } else {
                    withAnimation { offset = 0 }
                }
            }
            .onAppear {
                if isHungry {
                    withAnimation(.linear(duration: 0.1).repeatForever(autoreverses: true)) { offset = -3 }
                }
            }
    }
}

struct HeartsView: View {
    var body: some View {
        if #available(watchOS 8.0, iOS 15.0, *) {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    
                    for i in 0..<5 {
                        let speed = 20.0 + Double(i * 5)
                        let yPos = size.height - CGFloat((now * speed + Double(i * 20)).truncatingRemainder(dividingBy: Double(size.height + 20)))
                        
                        let xPos = size.width / 2 + CGFloat(sin(now * 3.0 + Double(i)) * 20.0)
                        
                        let opacity = yPos / size.height
                        context.opacity = opacity
                        context.draw(Text("❤️").font(.system(size: 14)), at: CGPoint(x: xPos, y: yPos))
                    }
                }
            }
            .frame(width: 120, height: 120)
        }
    }
}
