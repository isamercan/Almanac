import Foundation
#if canImport(UIKit)
import UIKit
#endif

// Haptic feedback — approximate mapping of native haptics.
// `HapticFeedbackType.Confirm` (day tap) → medium impact; `CLOCK_TICK` (wheel) → selection change.
enum Haptics {
  /// Fired on a valid day tap.
  static func dayTap() {
    #if canImport(UIKit)
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
    #endif
  }

  /// One drum tick as a value crosses the wheel center.
  static func wheelTick() {
    #if canImport(UIKit)
    let generator = UISelectionFeedbackGenerator()
    generator.selectionChanged()
    #endif
  }
}
