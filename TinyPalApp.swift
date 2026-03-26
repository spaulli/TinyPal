import SwiftUI
import WatchKit

@main
struct TinyPalApp: App {
    @AppStorage("isInitialized") private var isInitialized = false
    @State private var pet = PetModel()

    var body: some Scene {
        WindowGroup {
            if isInitialized {
                ContentView(pet: pet)
            } else {
                SelectionGridView(pet: pet, isInitialized: $isInitialized)
            }
        }
    }
}
