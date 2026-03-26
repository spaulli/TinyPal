#if !os(watchOS)
import Foundation
import SwiftUI

// Mocking the WatchKit Haptic Types
public enum WKHapticType {
    case click
    case success
    case failure
    case retry
    case start
    case stop
    case directionUp
    case directionDown
}

// Mocking the WatchKit Interface Device
public class WKInterfaceDevice {
    public static func current() -> WKInterfaceDevice {
        return WKInterfaceDevice()
    }
    
    public func play(_ type: WKHapticType) {
        // Redirecting to console.log equivalent
        print("[💻 Windows Simulation] HAPTIC FIRED: \(type)")
        
        // System beep using the standard ASCII bell character
        print("\u{0007}", terminator: "")
    }
}

// Mocking the Digital Crown Rotation modifier for standard SwiftUI targets (like macOS/Windows)
public extension View {
    func digitalCrownRotation<V>(_ binding: Binding<V>) -> some View where V : BinaryFloatingPoint {
        // Pass-through without crashing on non-watchOS platforms
        self
    }
}
#endif
