import SwiftUI

struct PetView: View {
    let petType: String
    let color: Color
    let isBreathing: Bool
    let isSleeping: Bool
    let showHappyEyes: Bool
    var mood: PetModel.Mood = .happy
    var forceSleepyEyes: Bool = false
    var forceO_Mouth: Bool = false
    var faceBlur: CGFloat = 0.0
    var armSweep: CGFloat = 0.0
    var legSweep: CGFloat = 0.0
    var tailRotation: CGFloat = 0.0
    var neckRotation: CGFloat = 0.0
    var scaleY: CGFloat = 1.0
    var scaleX: CGFloat = 1.0
    var hearts: Int = 4
    
    var body: some View {
        ZStack {
            // Heart Health Stack (Layered behind pet, offset left)
            VStack(spacing: 4) {
                ForEach((0..<4).reversed(), id: \.self) { index in
                    Image(systemName: index < hearts ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(index < hearts ? .red : .gray.opacity(0.5))
                        .shadow(color: index < hearts ? .red.opacity(0.6) : .clear, radius: 4)
                }
            }
            .offset(x: -45, y: -10)

            // Body Vector Shapes
            Group {
                if petType == "Bramble" {
                    BearShape(color: color, isBreathing: isBreathing, armSweep: armSweep, legSweep: legSweep)
                        .scaleEffect(x: scaleX, y: scaleY, anchor: .bottom)
                } else if petType == "Pip" {
                    DinoShape(color: color, isBreathing: false, isIcon: true)
                } else if petType == "Nova" {
                    SlimeShape(color: color, isBreathing: isBreathing)
                } else {
                    ChickShape(color: color, isBreathing: isBreathing, armSweep: armSweep, faceBlur: faceBlur)
                }
            }
            
            // Dynamic Face Overlay
            if !isSleeping {
                if petType == "Tweek" || petType == "Chick" {
                    TweekFace(isHappy: showHappyEyes, forceOMouth: forceO_Mouth)
                        .offset(y: isBreathing ? -2 : 2)
                } else if petType == "Nova" {
                    VStack(spacing: 4) {
                        BlinkView(isHappy: showHappyEyes)
                        MouthView(mood: mood, isEating: showHappyEyes)
                    }
                    .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .offset(y: isBreathing ? -2 : 2)
                }
            }
        }
        .frame(width: 110, height: 110)
    }

    }
}

// MARK: - Procedural Shape Characters

struct BearShape: View {
    let color: Color
    let isBreathing: Bool
    var armSweep: CGFloat = 0.0
    var legSweep: CGFloat = 0.0
    
    var body: some View {
        let darkBrown = Color(red: 139/255, green: 69/255, blue: 19/255)
        let lightBrown = Color(red: 210/255, green: 180/255, blue: 140/255)
        let muzzleColor = Color(red: 245/255, green: 222/255, blue: 179/255)
        
        let bearGradient = LinearGradient(
            gradient: Gradient(colors: [lightBrown, darkBrown]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        ZStack {
            // Legs (Visible at bottom)
            HStack(spacing: 40) {
                StumpyOvalPath()
                    .fill(darkBrown)
                    .frame(width: 35, height: 25)
                    .offset(y: legSweep)
                StumpyOvalPath()
                    .fill(darkBrown)
                    .frame(width: 35, height: 25)
                    .offset(y: -legSweep)
            }
            .offset(y: 40)
            
            // Ears (Back)
            ZStack {
                BearEarView(outerColor: darkBrown, innerColor: lightBrown)
                    .offset(x: -28, y: -45)
                BearEarView(outerColor: darkBrown, innerColor: lightBrown)
                    .offset(x: 28, y: -45)
            }
            
            // Main Body (Pear Shape)
            PearBodyPath()
                .fill(bearGradient)
                .frame(width: 90, height: 100)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
            
            // Arms (Front)
            ZStack {
                StumpyOvalPath()
                    .fill(darkBrown)
                    .frame(width: 25, height: 35)
                    .rotationEffect(.degrees(Double(armSweep)), anchor: .top)
                    .offset(x: -35, y: -10)
                
                StumpyOvalPath()
                    .fill(darkBrown)
                    .frame(width: 25, height: 35)
                    .rotationEffect(.degrees(Double(-armSweep)), anchor: .top)
                    .offset(x: 35, y: -10)
            }
            
            // Head Cluster
            ZStack {
                // Head Base
                BearHeadPath()
                    .fill(bearGradient)
                    .frame(width: 75, height: 70)
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                
                // Muzzle & Face Group
                ZStack {
                    // Tan Muzzle Patch
                    Ellipse()
                        .fill(muzzleColor)
                        .frame(width: 44, height: 28)
                        .offset(y: 10)
                    
                    // Nose Triangle
                    Triangle()
                        .fill(Color.black)
                        .frame(width: 10, height: 6)
                        .rotationEffect(.degrees(180))
                        .offset(y: 6)
                    
                    // Eyes only
                    BlinkView(isHappy: false)
                        .scaleEffect(0.7)
                        .offset(y: -4)
                }
            }
            .offset(y: -42)
        }
        .offset(y: isBreathing ? -3 : 3)
    }
}

struct BearEarView: View {
    let outerColor: Color
    let innerColor: Color
    var body: some View {
        ZStack {
            Circle().fill(outerColor).frame(width: 30, height: 30)
            Circle().fill(innerColor).frame(width: 15, height: 15)
        }
    }
}

struct PearBodyPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Match Preview.html: d="M 50 35 C 70 35, 95 65, 95 90 C 95 105, 75 110, 50 110 C 25 110, 5 105, 5 90 C 5 65, 30 35, 50 35"
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.32)) // M 50 35 (scaled)
        path.addCurve(to: CGPoint(x: w * 0.95, y: h * 0.82),
                      control1: CGPoint(x: w * 0.7, y: h * 0.32),
                      control2: CGPoint(x: w * 0.95, y: h * 0.59)) // C ... 95 90
        path.addCurve(to: CGPoint(x: w * 0.5, y: h),
                      control1: CGPoint(x: w * 0.95, y: h * 0.95),
                      control2: CGPoint(x: w * 0.75, y: h)) // C ... 50 110
        path.addCurve(to: CGPoint(x: w * 0.05, y: h * 0.82),
                      control1: CGPoint(x: w * 0.25, y: h),
                      control2: CGPoint(x: w * 0.05, y: h * 0.95)) // C ... 5 90
        path.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.32),
                      control1: CGPoint(x: w * 0.05, y: h * 0.59),
                      control2: CGPoint(x: w * 0.3, y: h * 0.32)) // C ... 
        return path
    }
}

struct BearHeadPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: w * 0.45, height: h * 0.45))
        return path
    }
}

struct StumpyOvalPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        return path
    }
}

struct SlimeShape: View {
    let color: Color
    let isBreathing: Bool
    
    @State private var dustOffsets: [CGFloat] = (0..<8).map { _ in CGFloat.random(in: -10...10) }
    @State private var dustSpeeds: [Double] = (0..<8).map { _ in Double.random(in: 1.5...3.0) }
    @State private var isAnimatingNova = false
    @State private var scaleX: CGFloat = 1.0
    @State private var scaleY: CGFloat = 1.0
    @State private var coreWhite: Double = 0.8
    @State private var pulseScale: CGFloat = 1.0
    @State private var isPulsingColor = false
    @State private var showSparkles = false
    @State private var flyOffset: CGFloat = 0.0
    @State private var jellyRotation: Double = 0.0
    @State private var wobbleAmplitude: CGFloat = 0.0
    @State private var impactPoint: CGPoint = CGPoint(x: 50, y: 50)
    
    private let fluidSpring = Animation.interactiveSpring(response: 0.9, dampingFraction: 0.7)
    
    var currentBaseTone: Color {
        isPulsingColor ? .cyan : color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.cyan.opacity(0.4))
                .frame(width: 120, height: 120)
                .blur(radius: 10)
                .scaleEffect((isBreathing ? 1.15 : 0.95) * pulseScale)
            
            ZStack {
                StarBlobWobblePath(wobble: wobbleAmplitude, tap: impactPoint)
                    .fill(currentBaseTone)
                StarBlobWobblePath(wobble: wobbleAmplitude, tap: impactPoint)
                    .fill(LinearGradient(gradient: Gradient(colors: [.cyan, .magenta]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .opacity(0.6)
                StarBlobWobblePath(wobble: wobbleAmplitude, tap: impactPoint)
                    .fill(RadialGradient(gradient: Gradient(colors: [Color.white.opacity(coreWhite), .clear]), center: .center, startRadius: 0, endRadius: 40))
                    .opacity(0.8)
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 2...6), height: CGFloat.random(in: 2...6))
                        .opacity(Double.random(in: 0.1...0.4))
                        .offset(x: CGFloat.random(in: -35...35) * scaleX, y: dustOffsets[i])
                        .animation(
                            Animation.easeInOut(duration: dustSpeeds[i])
                                .repeatForever(autoreverses: true),
                            value: dustOffsets
                        )
                }
            }
            .rotationEffect(.degrees(jellyRotation))
            
            if showSparkles {
                SparklesOverlay()
            }
        }
        .scaleEffect(x: scaleX * (isBreathing ? 1.05 : 1.0) * pulseScale, 
                     y: scaleY * (isBreathing ? 0.9 : 1.1) * pulseScale, anchor: .bottom)
        .offset(y: flyOffset)
        .frame(width: 100, height: 100)
    }
}

struct StarBlobWobblePath: Shape {
    var wobble: CGFloat
    var tap: CGPoint
    var animatableData: CGFloat {
        get { wobble }
        set { wobble = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let cX = w / 2
        let cY = h / 2
        let points = 5
        let r = min(w, h) / 2
        let innerR = r * 0.4
        var starPoints: [CGPoint] = []
        for i in 0..<points {
            let theta1 = .pi * 2 / Double(points) * Double(i) - .pi / 2
            let theta2 = .pi * 2 / Double(points) * Double(i) - .pi / 2 + .pi / Double(points)
            let p1 = CGPoint(x: cX + cos(theta1)*r, y: cY + sin(theta1)*r)
            let p2 = CGPoint(x: cX + cos(theta2)*innerR, y: cY + sin(theta2)*innerR)
            starPoints.append(applyWobble(to: p1, center: CGPoint(x: cX, y: cY)))
            starPoints.append(applyWobble(to: p2, center: CGPoint(x: cX, y: cY)))
        }
        path.move(to: starPoints[(starPoints.count - 1)])
        for i in 0..<starPoints.count {
            let p1 = starPoints[i % starPoints.count]
            let p2 = starPoints[(i + 1) % starPoints.count]
            path.addArc(tangent1End: p1, tangent2End: p2, radius: 25)
        }
        path.closeSubpath()
        return path
    }
    private func applyWobble(to p: CGPoint, center: CGPoint) -> CGPoint {
        if wobble == 0 { return p }
        let dist = hypot(p.x - tap.x, p.y - tap.y)
        let ripple = sin(dist * 0.2 - wobble * 20) * (wobble * 15)
        let dx = p.x - center.x
        let dy = p.y - center.y
        let angle = atan2(dy, dx)
        return CGPoint(x: p.x + cos(angle)*ripple, y: p.y + sin(angle)*ripple)
    }
}

struct SparklesOverlay: View {
    var body: some View {
        if #available(watchOS 8.0, iOS 15.0, *) {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    for i in 0..<15 {
                        let speed = 40.0 + Double(i * 10)
                        let timeOffset = now * speed
                        let rad = Double(i) * .pi / 7.5
                        let dist = (timeOffset.truncatingRemainder(dividingBy: 60.0))
                        let x = size.width/2 + cos(rad) * dist
                        let y = size.height/2 + sin(rad) * dist
                        let opacity = 1.0 - (dist / 60.0)
                        context.opacity = max(0, opacity)
                        context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 3, height: 3)), with: .color(.white))
                    }
                }
            }
        }
    }
}

struct DinoShape: View {
    let color: Color
    let isBreathing: Bool
    var tailRotation: CGFloat = 0
    var neckRotation: CGFloat = 0
    var isIcon: Bool = false
    
    var body: some View {
        let greenColor = Color(red: 60/255, green: 179/255, blue: 113/255) // #3CB371
        let tealColor = Color(red: 32/255, green: 178/255, blue: 170/255) // #20B2AA
        let muzzleColor = Color(red: 72/255, green: 209/255, blue: 204/255) // Lighter teal muzzle
        let plateColor = Color.orange
        
        let pipGradient = LinearGradient(
            gradient: Gradient(colors: [tealColor, greenColor]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        ZStack {
            // Legs (Back layer)
            HStack(spacing: isIcon ? 20 : 30) {
                Capsule().fill(greenColor.opacity(0.6)).frame(width: isIcon ? 10 : 14, height: isIcon ? 18 : 26).offset(x: -8, y: isIcon ? 28 : 38)
                Capsule().fill(greenColor.opacity(0.6)).frame(width: isIcon ? 10 : 14, height: isIcon ? 18 : 26).offset(x: 10, y: isIcon ? 28 : 38)
            }
            .offset(x: -5)

            // MASTER BODY GROUP
            ZStack {
                // Spine Plates
                if !isIcon {
                    ZStack {
                        Ellipse().fill(plateColor).frame(width: 12, height: 16).rotationEffect(.degrees(-30)).offset(x: -48, y: 20)
                        Ellipse().fill(plateColor).frame(width: 18, height: 24).rotationEffect(.degrees(-45)).offset(x: -30, y: 5)
                        Ellipse().fill(plateColor).frame(width: 22, height: 30).rotationEffect(.degrees(-60)).offset(x: -10, y: -15)
                        Ellipse().fill(plateColor).frame(width: 24, height: 32).rotationEffect(.degrees(-75)).offset(x: 15, y: -25)
                        Ellipse().fill(plateColor).frame(width: 20, height: 28).rotationEffect(.degrees(-90)).offset(x: 35, y: -30)
                    }
                }
                
                // Wide, Round Body Path
                PipRoundBodyPath(tailAngle: tailRotation, neckAngle: neckRotation)
                    .fill(pipGradient)
                    .shadow(color: .black.opacity(0.15), radius: isIcon ? 2 : 6, x: 2, y: 2)
                    .overlay(
                        PipRoundBodyPath(tailAngle: tailRotation, neckAngle: neckRotation)
                            .stroke(Color.black.opacity(0.15), lineWidth: isIcon ? 4 : 12)
                            .blur(radius: isIcon ? 2 : 6)
                            .mask(PipRoundBodyPath(tailAngle: tailRotation, neckAngle: neckRotation))
                    )

                // Head Assembly
                ZStack {
                    Circle()
                        .fill(tealColor)
                        .frame(width: isIcon ? 32 : 48, height: isIcon ? 32 : 48)
                    
                    if !isIcon {
                        Ellipse()
                            .fill(muzzleColor)
                            .frame(width: 30, height: 24)
                            .offset(x: 18, y: 10)
                        
                        ZStack {
                            Circle().fill(Color.black).frame(width: 10, height: 12)
                            Circle().fill(Color.white).frame(width: 4, height: 4).offset(x: 2, y: -3)
                        }
                        .offset(x: 4, y: -6)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .blur(radius: 3)
                            .offset(x: 16, y: -16)
                    }
                }
                .offset(x: isIcon ? 35 : 55, y: isIcon ? -50 : -75)
                .rotationEffect(.degrees(Double(neckRotation * 0.8)), anchor: .init(x: 0.1, y: 1.5))
            }
            .rotationEffect(.degrees(Double(tailRotation * 0.2)), anchor: .bottom)

            // Front Legs
            HStack(spacing: isIcon ? 15 : 24) {
                Capsule().fill(greenColor.opacity(0.9)).frame(width: isIcon ? 12 : 18, height: isIcon ? 22 : 32).offset(x: -5, y: isIcon ? 30 : 40)
                Capsule().fill(greenColor.opacity(0.9)).frame(width: isIcon ? 12 : 18, height: isIcon ? 22 : 32).offset(x: 12, y: isIcon ? 30 : 40)
            }
            .offset(x: -5)
        }
        .offset(y: isBreathing ? -2 : 2)
        .frame(width: isIcon ? 60 : 100, height: isIcon ? 60 : 100)
    }
}

struct PipRoundBodyPath: Shape {
    var tailAngle: CGFloat
    var neckAngle: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(tailAngle, neckAngle) }
        set {
            tailAngle = newValue.first
            neckAngle = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let neckX = sin(neckAngle * .pi / 180) * 12
        let neckY = (1 - cos(neckAngle * .pi / 180)) * 10
        
        let tailX = sin(tailAngle * .pi / 180) * 20
        let tailY = (1 - cos(tailAngle * .pi / 180)) * 15

        // Neck tip (pinned to head center)
        path.move(to: CGPoint(x: w * 0.55 + neckX, y: h * 0.1 - neckY))
        
        // WIDER BACK FLOW
        path.addCurve(to: CGPoint(x: w * 0.8, y: h * 0.4),
                      control1: CGPoint(x: w * 0.65 + neckX, y: h * 0.15 - neckY),
                      control2: CGPoint(x: w * 0.95, y: h * 0.3))
        
        // HEAVIER PEAR BELLY
        path.addCurve(to: CGPoint(x: w * 0.6, y: h * 0.85),
                      control1: CGPoint(x: w * 1.1, y: h * 0.6),
                      control2: CGPoint(x: w * 1.0, y: h * 1.0))
        
        // THICK ROUND TAIL
        path.addCurve(to: CGPoint(x: w * -0.05 - tailX, y: h * 0.82 + tailY),
                      control1: CGPoint(x: w * 0.3, y: h * 0.9),
                      control2: CGPoint(x: w * 0.05 - tailX, y: h * 1.05 + tailY))
        
        // Tail back to Belly underside
        path.addCurve(to: CGPoint(x: w * 0.3, y: h * 0.82),
                      control1: CGPoint(x: w * -0.1 - tailX, y: h * 0.6 + tailY),
                      control2: CGPoint(x: w * 0.1, y: h * 0.82))
        
        // Ground Contact
        path.addQuadCurve(to: CGPoint(x: w * 0.85, y: h * 0.82),
                          control: CGPoint(x: w * 0.55, y: h * 0.98))
        
        // Front Silhouette (pinned up to neck base)
        path.addCurve(to: CGPoint(x: w * 0.55 + neckX, y: h * 0.1 - neckY),
                      control1: CGPoint(x: w * 1.0, y: h * 0.7),
                      control2: CGPoint(x: w * 0.45 + neckX, y: h * 0.3 - neckY))
        
        path.closeSubpath()
        return path
    }
}

// (PipUnifiedBodyPath removed for wider redesign)

// (PipTailPath, PipNeckPath, PipBellyPath removed for unification)

// (PipSBodyPath removed in favor of multi-part layering)

struct RoundedTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addArc(tangent1End: CGPoint(x: w, y: h), tangent2End: CGPoint(x: 0, y: h), radius: 5)
        path.addArc(tangent1End: CGPoint(x: 0, y: h), tangent2End: CGPoint(x: w * 0.5, y: 0), radius: 5)
        path.addArc(tangent1End: CGPoint(x: w * 0.5, y: 0), tangent2End: CGPoint(x: w, y: h), radius: 5)
        path.closeSubpath()
        return path
    }
}

struct ChickShape: View {
    let color: Color
    let isBreathing: Bool
    var armSweep: CGFloat = 0.0
    var faceBlur: CGFloat = 0.0
    var body: some View {
        ZStack {
            LegsPath()
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: 100, height: 100)
            HStack(spacing: 50) {
                TeardropPath()
                    .fill(color)
                    .frame(width: 25, height: 45)
                    .rotationEffect(.degrees(isBreathing ? 40 : 10), anchor: .top)
                    .rotationEffect(.degrees(Double(armSweep)), anchor: .top)
                    .blur(radius: faceBlur > 0 ? faceBlur : 0)
                TeardropPath()
                    .fill(color)
                    .frame(width: 25, height: 45)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .rotationEffect(.degrees(isBreathing ? -40 : -10), anchor: .top)
                    .rotationEffect(.degrees(Double(-armSweep)), anchor: .top)
                    .blur(radius: faceBlur > 0 ? faceBlur : 0)
            }
            .offset(y: -10)
            FluffyScallopPath()
                .fill(color)
                .frame(width: 90, height: 90)
        }
        .scaleEffect(isBreathing ? 1.05 : 1.0)
    }
}

struct FluffyScallopPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let cX = w / 2
        let cY = h / 2
        let r = min(w, h) / 2
        let bumps = 12
        let bumpRadius: CGFloat = 8
        var points: [CGPoint] = []
        for i in 0..<bumps {
            let angle = .pi * 2 / Double(bumps) * Double(i)
            points.append(CGPoint(x: cX + cos(angle) * r, y: cY + sin(angle) * r))
        }
        path.move(to: points[0])
        for i in 0..<bumps {
            let p1 = points[i]
            let p2 = points[(i + 1) % bumps]
            let midX = (p1.x + p2.x) / 2
            let midY = (p1.y + p2.y) / 2
            let dx = p2.x - p1.x
            let dy = p2.y - p1.y
            let dist = hypot(dx, dy)
            let nx = dy / dist
            let ny = -dx / dist
            let cp = CGPoint(x: midX + nx * bumpRadius * 1.5, y: midY + ny * bumpRadius * 1.5)
            path.addQuadCurve(to: p2, control: cp)
        }
        return path
    }
}

struct LegsPath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cX = rect.midX
        let cY = rect.midY
        p.move(to: CGPoint(x: cX - 15, y: cY + 30))
        p.addLine(to: CGPoint(x: cX - 15, y: cY + 55))
        p.addLine(to: CGPoint(x: cX - 25, y: cY + 60))
        p.move(to: CGPoint(x: cX - 15, y: cY + 55))
        p.addLine(to: CGPoint(x: cX - 5, y: cY + 60))
        p.move(to: CGPoint(x: cX + 15, y: cY + 30))
        p.addLine(to: CGPoint(x: cX + 15, y: cY + 55))
        p.addLine(to: CGPoint(x: cX + 5, y: cY + 60))
        p.move(to: CGPoint(x: cX + 15, y: cY + 55))
        p.addLine(to: CGPoint(x: cX + 25, y: cY + 60))
        return p
    }
}

struct TeardropPath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addCurve(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.7), control1: CGPoint(x: rect.maxX * 1.2, y: rect.minY), control2: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addCurve(to: CGPoint(x: rect.minX, y: rect.maxY * 0.7), control1: CGPoint(x: rect.maxX, y: rect.maxY * 1.3), control2: CGPoint(x: rect.minX, y: rect.maxY * 1.3))
        p.addCurve(to: CGPoint(x: rect.midX, y: rect.minY), control1: CGPoint(x: rect.minX, y: rect.maxY), control2: CGPoint(x: rect.minX * -0.2, y: rect.minY))
        return p
    }
}

struct TweekFace: View {
    var isHappy: Bool
    var forceOMouth: Bool
    @State private var blinkScaleY: CGFloat = 1.0
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 20) {
                if isHappy {
                    Text("^").font(.system(size: 30, weight: .black)).foregroundColor(.black)
                    Text("^").font(.system(size: 30, weight: .black)).foregroundColor(.black)
                } else {
                    ZStack {
                        Circle().fill(Color.black).frame(width: 14, height: 14)
                        Circle().fill(Color.white).frame(width: 4, height: 4).offset(x: 4, y: -4)
                    }
                    .scaleEffect(y: blinkScaleY)
                    ZStack {
                        Circle().fill(Color.black).frame(width: 14, height: 14)
                        Circle().fill(Color.white).frame(width: 4, height: 4).offset(x: 4, y: -4)
                    }
                    .scaleEffect(y: blinkScaleY)
                }
            }
            VStack(spacing: forceOMouth ? 4 : 0) {
                Triangle().fill(Color.orange).frame(width: 14, height: 8).rotationEffect(.degrees(180))
                Triangle().fill(Color.orange).frame(width: 14, height: 8)
            }
            .offset(y: -5)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...5), repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.1)) { blinkScaleY = 0.1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) { blinkScaleY = 1.0 }
                }
            }
        }
    }
}

struct BlinkView: View {
    var isHappy: Bool
    @State private var scaleY: CGFloat = 1.0
    var body: some View {
        HStack(spacing: 20) {
            if isHappy {
                Text("^").font(.system(size: 30, weight: .black)).foregroundColor(.black)
                Text("^").font(.system(size: 30, weight: .black)).foregroundColor(.black)
            } else {
                ZStack {
                    Capsule().fill(Color.black).frame(width: 12, height: 22)
                    Circle().fill(Color.white).frame(width: 4, height: 4).offset(x: 3, y: -7)
                }
                .scaleEffect(y: scaleY)
                ZStack {
                    Capsule().fill(Color.black).frame(width: 12, height: 22)
                    Circle().fill(Color.white).frame(width: 4, height: 4).offset(x: 3, y: -7)
                }
                .scaleEffect(y: scaleY)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...5), repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.1)) { scaleY = 0.1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) { scaleY = 1.0 }
                }
            }
        }
    }
}

struct MouthView: View {
    var mood: PetModel.Mood
    var isEating: Bool
    var body: some View {
        Group {
            if isEating {
                Circle().stroke(Color.black, lineWidth: 4).frame(width: 14, height: 14).opacity(0.8)
            } else if mood == .happy {
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 0))
                    p.addQuadCurve(to: CGPoint(x: 20, y: 0), control: CGPoint(x: 10, y: 15))
                }
                .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 20, height: 10)
            } else if mood == .sad {
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 5))
                    p.addQuadCurve(to: CGPoint(x: 20, y: 5), control: CGPoint(x: 10, y: -5))
                }
                .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 20, height: 10)
            } else {
                Capsule().fill(Color.black).frame(width: 16, height: 4)
            }
        }
        .padding(.top, 2)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
