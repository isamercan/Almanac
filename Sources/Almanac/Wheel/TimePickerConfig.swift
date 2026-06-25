import SwiftUI

/// Tunable configuration for the drum time pickers. ///
/// `itemHeight` / `visibleItems` define the layout; `fadingPower` controls the cosine alpha falloff.
/// The spring/decay knobs (`snapStiffness`, `damping`, `decayFriction`) don't map onto
/// SwiftUI's `ScrollView` physics, which handles deceleration + snapping natively; they are kept for
/// API parity and documented as approximate.
public struct TimePickerConfig {
  public var itemHeight: CGFloat = 34
  public var visibleItems: Int = 5
  public var fontSize: CGFloat = 23
  public var fontWeight: Font.Weight = .light
  public var textColor: Color = CalendarColors.ink
  /// Alpha = (1 − |angle| / (π/2))^fadingPower. Default 4 for a smooth fade.
  public var fadingPower: CGFloat = 4
  /// Whether a selection-feedback tick fires as a value crosses the wheel center. Default true.
  /// Set to false to silence the drum (parity with the calendar's `hapticsEnabled`).
  public var hapticsEnabled: Bool = true

  // Parity-only physics knobs (see note above).
  public var snapStiffness: CGFloat = 1
  public var damping: CGFloat = 1
  public var decayFriction: CGFloat = 1

  public init(
    itemHeight: CGFloat = 34,
    visibleItems: Int = 5,
    fontSize: CGFloat = 23,
    fontWeight: Font.Weight = .light,
    textColor: Color = CalendarColors.ink,
    fadingPower: CGFloat = 4,
    hapticsEnabled: Bool = true)
  {
    precondition(visibleItems % 2 == 1, "visibleItems must be an odd integer!")
    self.itemHeight = itemHeight
    self.visibleItems = visibleItems
    self.fontSize = fontSize
    self.fontWeight = fontWeight
    self.textColor = textColor
    self.fadingPower = fadingPower
    self.hapticsEnabled = hapticsEnabled
  }

  /// Total height of the wheel viewport.
  public var wheelHeight: CGFloat { itemHeight * CGFloat(visibleItems) }
  /// Multiplier of `itemHeight`; larger = flatter drum.
  public var cylinderRadius: CGFloat { 2.8 * (CGFloat(visibleItems) / 5.0) }
  /// Rows above/below center.
  var halfVisible: Int { visibleItems / 2 }

  var font: Font {
    Font.system(size: fontSize, weight: fontWeight).monospacedDigit()  // tnum
  }
}
