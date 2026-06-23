import SwiftUI

/// The single, comprehensive design configuration for the calendar: colors (`theme`), text styles
/// (`typography`) and numeric tokens (`metrics`). Inject it with `.calendarStyle(_:)`; everything
/// defaults to the stock look, so override only what you need.
///
///     var style = CalendarStyle.standard
///     style.theme.ink = .indigo
///     style.metrics.footerCornerRadius = 12
///     style.typography.dayNumber.size = 18
///     someView.calendarStyle(style)
public struct CalendarStyle: Equatable, Sendable {
  public var theme: CalendarTheme
  public var typography: CalendarTypography
  public var metrics: CalendarMetrics

  public init(
    theme: CalendarTheme = .standard,
    typography: CalendarTypography = CalendarTypography(),
    metrics: CalendarMetrics = CalendarMetrics())
  {
    self.theme = theme
    self.typography = typography
    self.metrics = metrics
  }

  public static let standard = CalendarStyle()
}

private struct CalendarStyleKey: EnvironmentKey {
  static let defaultValue = CalendarStyle.standard
}

extension EnvironmentValues {
  var calendarStyle: CalendarStyle {
    get { self[CalendarStyleKey.self] }
    set { self[CalendarStyleKey.self] = newValue }
  }
}

public extension View {
  /// Overrides the full calendar design (colors + typography + metrics) for this subtree.
  func calendarStyle(_ style: CalendarStyle) -> some View {
    environment(\.calendarStyle, style)
  }

  /// Convenience: override only the colors, leaving typography/metrics at their current values.
  func calendarTheme(_ theme: CalendarTheme) -> some View {
    transformEnvironment(\.calendarStyle) { $0.theme = theme }
  }
}
