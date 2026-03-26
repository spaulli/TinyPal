import SwiftUI
import WatchKit

struct OnboardingView: View {
    @Bindable var pet: PetModel
    @Binding var isInitialized: Bool
    
    @State private var selectedIndex = 0
    @State private var showNaming = false
    
    let petTypes = [
        ("Bramble", "pawprint.fill"),
        ("Pip", "tortoise.fill"),
        ("Nova", "sparkles"),
        ("Tweek", "bird.fill")
    ]
    
    var body: some View {
        if showNaming {
            NamingView(pet: pet, isInitialized: $isInitialized)
        } else {
            VStack {
                TabView(selection: $selectedIndex) {
                    ForEach(0..<petTypes.count, id: \.self) { index in
                        VStack(spacing: 8) {
                            PetView(petType: petTypes[index].0, color: .primary, isBreathing: true, isSleeping: false, showHappyEyes: false)
                                .frame(width: 120, height: 120)
                                .scaleEffect(1.5) // Scale up the base pet view in the onboarding screen
                            
                            Text(petTypes[index].0)
                                .font(.headline)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
                
                Button(action: {
                    WKInterfaceDevice.current().play(.success)
                    pet.petType = petTypes[selectedIndex].0
                    showNaming = true
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                        .frame(width: 80, height: 80)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct NamingView: View {
    @Bindable var pet: PetModel
    @Binding var isInitialized: Bool
    
    @State private var nameInput: String = ""
    
    var body: some View {
        VStack {
            Text("Name your \(pet.petType)")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            TextField("Pet Name", text: $nameInput)
                .textContentType(.name)
                .padding(.vertical, 8)
            
            Spacer()
            
            Button(action: {
                let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    WKInterfaceDevice.current().play(.success)
                    pet.petName = trimmed
                    pet.initializeDates()
                    UserDefaults.standard.set(true, forKey: "isInitialized")
                    isInitialized = true
                }
            }) {
                Text("Confirm")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(nameInput.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .cornerRadius(20)
            }
            .buttonStyle(.plain)
            .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
    }
}
