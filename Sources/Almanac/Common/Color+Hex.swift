import SwiftUI
import UIKit

extension Color {
  /// Builds a color from a packed 0xAARRGGBB integer (alpha, red, green, blue).
  init(argb: UInt32) {
    let a = Double((argb >> 24) & 0xFF) / 255.0
    let r = Double((argb >> 16) & 0xFF) / 255.0
    let g = Double((argb >> 8) & 0xFF) / 255.0
    let b = Double(argb & 0xFF) / 255.0
    self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
  }

  /// An adaptive color that resolves differently in light vs dark mode.
  init(light: Color, dark: Color) {
    self = Color(UIColor { traits in
      traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
    })
  }

  /// Convenience for building an adaptive color from two packed 0xAARRGGBB integers.
  init(lightARGB: UInt32, darkARGB: UInt32) {
    self.init(light: Color(argb: lightARGB), dark: Color(argb: darkARGB))
  }

  /// Packs the color back into 0xAARRGGBB. Used for the legend's stable identity key.
  var argbValue: UInt32 {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
    func clamp(_ v: CGFloat) -> UInt32 { UInt32((max(0, min(1, v)) * 255).rounded()) }
    return (clamp(a) << 24) | (clamp(r) << 16) | (clamp(g) << 8) | clamp(b)
  }
}
