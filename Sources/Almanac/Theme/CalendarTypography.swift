import SwiftUI

// Reused text styles. Uses the system (San Francisco) font — the SwiftUI default — at fixed
// design sizes with Light/Medium/SemiBold weights.
// Sizes scale with Dynamic Type via a per-style `relativeTo` text-style anchor.
// Temporary home until a shared SwiftUI theme exists.

/// A reusable text style: the system font at a base size + weight, scaling with Dynamic Type
/// relative to `relativeTo`, plus optional letter spacing.
public struct CalendarTextStyle: Equatable, Sendable {
  public var size: CGFloat
  public var weight: Font.Weight
  public var tracking: CGFloat
  /// Dynamic Type anchor used to scale `size`.
  public var relativeTo: Font.TextStyle

  public init(size: CGFloat, weight: Font.Weight, tracking: CGFloat = 0, relativeTo: Font.TextStyle = .body) {
    self.size = size
    self.weight = weight
    self.tracking = tracking
    self.relativeTo = relativeTo
  }
}

/// The set of text styles used across the calendar. Defaults match the original design.
public struct CalendarTypography: Equatable, Sendable {
  public var dayNumber = CalendarTextStyle(size: 16, weight: .medium, relativeTo: .body)
  public var monthTitle = CalendarTextStyle(size: 14, weight: .semibold, tracking: -0.02, relativeTo: .subheadline)
  public var weekdayLabel = CalendarTextStyle(size: 14, weight: .medium, relativeTo: .footnote)
  public var topBarTitle = CalendarTextStyle(size: 18, weight: .semibold, relativeTo: .headline)
  public var dateLabel = CalendarTextStyle(size: 16, weight: .semibold, relativeTo: .body)
  public var button = CalendarTextStyle(size: 16, weight: .semibold, relativeTo: .body)
  public var legend = CalendarTextStyle(size: 14, weight: .medium, relativeTo: .footnote)
  /// Year-overview heading (`CalendarYearView` multi-year sections).
  public var yearTitle = CalendarTextStyle(size: 22, weight: .bold, relativeTo: .title2)
  /// Mini-month title + day numbers in the year overview.
  public var miniMonthTitle = CalendarTextStyle(size: 13, weight: .semibold, relativeTo: .caption)
  public var miniMonthDay = CalendarTextStyle(size: 9, weight: .regular, relativeTo: .caption2)

  public init() {}
}

/// Applies a `CalendarTextStyle`, scaling the size with Dynamic Type (`@ScaledMetric`).
private struct CalendarTextStyleModifier: ViewModifier {
  let style: CalendarTextStyle
  @ScaledMetric private var scaledSize: CGFloat

  init(_ style: CalendarTextStyle) {
    self.style = style
    _scaledSize = ScaledMetric(wrappedValue: style.size, relativeTo: style.relativeTo)
  }

  func body(content: Content) -> some View {
    content
      .font(.system(size: scaledSize, weight: style.weight))
      .tracking(style.tracking)
  }
}

extension View {
  /// Applies a `CalendarTextStyle` (Dynamic-Type-scaled font + letter spacing).
  func calendarTextStyle(_ style: CalendarTextStyle) -> some View {
    modifier(CalendarTextStyleModifier(style))
  }
}
