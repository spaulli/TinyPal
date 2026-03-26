import SwiftUI

@Observable
class PetModel {
    var happiness: Double = 100
    var energy: Double = 100
    
    var hearts: Int {
        let now = Date()
        let hoursSinceFed = now.timeIntervalSince(lastFedDate) / 3600.0
        return max(1, 4 - Int(max(0, hoursSinceFed) / 4.0))
    }
    
    // Persistent properties
    var petType: String = UserDefaults.standard.string(forKey: "petType") ?? "Bramble" {
        didSet { UserDefaults.standard.set(petType, forKey: "petType") }
    }
    
    var displayName: String {
        return petType
    }
    
    // Color Swapping (Hex-based for stability)
    var bodyColorHex: String = "#3498db" // Default Blue
    
    var bodyColor: Color {
        Color(hex: bodyColorHex)
    }
    
    // Time Persistence Dates
    var lastFedDate: Date {
        get { UserDefaults.standard.object(forKey: "lastFedDate") as? Date ?? Date() }
        set { UserDefaults.standard.set(newValue, forKey: "lastFedDate") }
    }
    var lastPlayedDate: Date {
        get { UserDefaults.standard.object(forKey: "lastPlayedDate") as? Date ?? Date() }
        set { UserDefaults.standard.set(newValue, forKey: "lastPlayedDate") }
    }
    var accountCreatedDate: Date {
        get { UserDefaults.standard.object(forKey: "accountCreatedDate") as? Date ?? Date() }
        set { UserDefaults.standard.set(newValue, forKey: "accountCreatedDate") }
    }
    
    // Mood evaluations
    enum Mood { case happy, sad, neutral }
    
    var petMood: Mood {
        if hearts == 4 { return .happy }
        if hearts <= 1 { return .sad }
        return .neutral
    }
    
    var dayCount: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: accountCreatedDate)
        let today = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: today)
        return (components.day ?? 0) + 1
    }
    
    // Weather Magic Simulator
    var currentCondition: String = "Sunny"
    
    func cycleColor() {
        let hexes = ["#3498db", "#e91e63", "#e67e22", "#2ecc71", "#f1c40f", "#9b59b6"]
        if let idx = hexes.firstIndex(of: bodyColorHex) {
            bodyColorHex = hexes[(idx + 1) % hexes.count]
        } else {
            bodyColorHex = hexes[0]
        }
    }
    
    var imageAssetName: String {
        switch petType {
        case "Bramble": return "pawprint.fill"
        case "Pip": return "tortoise.fill"
        case "Nova": return "sparkles"
        case "Tweek": return "bird.fill"
        default: return "questionmark.app.fill"
        }
    }
    
    var isNapping: Bool {
        return hearts <= 1
    }
    
    private var decayTimer: Timer?
    
    init() {
        startDecay()
        updatePetStatus()
    }
    
    func updatePetStatus() {
        let now = Date()
        
        let hoursSincePlayed = now.timeIntervalSince(lastPlayedDate) / 3600.0
        if hoursSincePlayed > 0 {
            happiness = max(0, happiness - (hoursSincePlayed * 5))
            lastPlayedDate = now
        }
    }
    
    func startDecay() {
        decayTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updatePetStatus()
        }
    }
    
    func feed() {
        lastFedDate = Date()
    }
    
    func pet() {
        happiness = min(100, happiness + 20)
        lastPlayedDate = Date()
    }
    
    func play() {
        energy = max(0, energy - 10)
        happiness = min(100, happiness + 20)
        lastPlayedDate = Date()
    }
    
    func initializeDates() {
        let now = Date()
        accountCreatedDate = now
        lastFedDate = now
        lastPlayedDate = now
    }
}

// MARK: - Color Hex Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
