import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    
    func playEatSound() {
        playSound(named: "eat", ext: "wav")
    }
    
    func playGiggleSound() {
        playSound(named: "giggle", ext: "wav")
    }
    
    func playPopSound() {
        playSound(named: "pop", ext: "wav")
    }
    
    func playClinkSound() {
        playSound(named: "clink", ext: "wav")
    }
    
    func playPeekabooSound() {
        playSound(named: "peekaboo", ext: "wav")
    }
    
    func playMuffledGiggle() {
        playSound(named: "muffled_giggle", ext: "wav")
    }
    
    func playChirp() {
        playSound(named: "chirp", ext: "wav")
    }
    
    private func playSound(named name: String, ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Failed to play sound \(name): \(error.localizedDescription)")
        }
    }
}
