import SwiftUI

// Confetti Engine
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size * 1.5)
                        .position(x: particle.x, y: particle.y)
                        .rotationEffect(.degrees(particle.rotation))
                        .opacity(particle.opacity)
                        .animation(
                            Animation.linear(duration: particle.duration)
                                .delay(particle.delay),
                            value: particle.y
                        )
                        .animation(
                            Animation.linear(duration: particle.duration)
                                .delay(particle.delay),
                            value: particle.rotation
                        )
                        .animation(
                            Animation.easeIn(duration: particle.duration * 0.3)
                                .delay(particle.delay + particle.duration * 0.7),
                            value: particle.opacity
                        )
                }
            }
            .onAppear {
                createConfetti(in: geo.size)
            }
        }
        // Ignores safe area to allow falling fully out of view
        .edgesIgnoringSafeArea(.all)
    }
    
    private func createConfetti(in size: CGSize) {
        let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple]
        var newParticles: [ConfettiParticle] = []
        for _ in 0..<40 {
            let startX = CGFloat.random(in: 0...size.width)
            let particle = ConfettiParticle(
                x: startX,
                y: -50,
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...8),
                rotation: Double.random(in: 0...360),
                opacity: 1.0,
                duration: Double.random(in: 2.0...4.0),
                delay: Double.random(in: 0...1.5)
            )
            newParticles.append(particle)
        }
        particles = newParticles
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            for i in 0..<particles.count {
                particles[i].y += size.height + 150
                particles[i].rotation += Double.random(in: 180...720)
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    var rotation: Double
    var opacity: Double
    var duration: Double
    var delay: Double
}
