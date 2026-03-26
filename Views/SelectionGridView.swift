import SwiftUI
import WatchKit

// MARK: - SelectionGridView

struct SelectionGridView: View {
    @Bindable var pet: PetModel
    @Binding var isInitialized: Bool

    @State private var pressedIndex: Int? = nil

    private let petTypes: [(name: String, color: Color, hex: String)] = [
        ("Bramble", Color(red: 0.82, green: 0.71, blue: 0.55), "#d1b68c"),
        ("Pip",     Color(red: 0.12, green: 0.70, blue: 0.67), "#1eb3aa"),
        ("Nova",    Color(red: 0.00, green: 1.00, blue: 1.00), "#00ffff"),
        ("Tweek",   Color(red: 1.00, green: 0.75, blue: 0.20), "#ffbf33")
    ]

    var body: some View {
        GeometryReader { geo in
                let cellW = geo.size.width  / 2
                let cellH = geo.size.height / 2

                ZStack {
                    // Background
                    Color(white: 0.08)
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 0) {
                        // Row 1: Bramble | Pip
                        HStack(spacing: 0) {
                            petCell(index: 0, width: cellW, height: cellH)
                            petCell(index: 1, width: cellW, height: cellH)
                        }
                        // Row 2: Nova | Tweek
                        HStack(spacing: 0) {
                            petCell(index: 2, width: cellW, height: cellH)
                            petCell(index: 3, width: cellW, height: cellH)
                        }
                    }
                }
        }
        .edgesIgnoringSafeArea(.all)
    }

    // MARK: - Individual Cell

    @ViewBuilder
    private func petCell(index: Int, width: CGFloat, height: CGFloat) -> some View {
        let info = petTypes[index]
        let isPressed = pressedIndex == index

        Button {
            handleSelection(index: index)
        } label: {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(white: 0.18),
                                Color(white: 0.12)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(info.color.opacity(0.35), lineWidth: 1.5)
                    )
                    .padding(4)

                VStack(spacing: 4) {
                    // Static pet preview (no breathing animation)
                    PetView(
                        petType: info.name,
                        color: info.color,
                        isBreathing: false,
                        isSleeping: false,
                        showHappyEyes: false,
                        mood: .happy
                    )
                    .frame(width: 54, height: 54)
                    .scaleEffect(0.75)

                    // Pet name label
                    Text(info.name)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
            }
            .frame(width: width, height: height)
            .scaleEffect(isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Selection Logic

    private func handleSelection(index: Int) {
        pressedIndex = index

        // Haptic pulse
        WKInterfaceDevice.current().play(.success)

        // Happy chirp sound
        AudioManager.shared.playGiggleSound()

        // Set the pet type and initialize
        pet.petType = petTypes[index].name
        pet.bodyColorHex = petTypes[index].hex
        pet.initializeDates()

        // Brief visual press, then navigate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            pressedIndex = nil
            withAnimation(.easeInOut(duration: 0.25)) {
                UserDefaults.standard.set(true, forKey: "isInitialized")
                isInitialized = true
            }
        }
    }
}
