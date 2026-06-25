import SwiftUI

// Named alternate color palettes, on top of `CalendarTheme.standard`. Each is adaptive (light/dark)
// and varies only the accent tokens (selected fill, in-range tint, today ring, holiday dot); the
// neutral tokens (surface, lines, weekend labels, disabled chrome) are inherited from the stock
// palette so the calendar still reads as a normal calendar wearing a different accent.
//
// `.standard` is untouched, so the default look stays pixel-stable (the snapshot suite enforces it).

public extension CalendarTheme {
  /// Teal / blue.
  static let ocean = CalendarTheme(
    ink: Color(lightARGB: 0xFF0A7EA4, darkARGB: 0xFF5BC2E7),
    onInk: Color(lightARGB: 0xFFFFFFFF, darkARGB: 0xFF06222B),
    surface: CalendarColors.surface,
    line: CalendarColors.line,
    weekendText: CalendarColors.weekendText,
    todayRing: Color(lightARGB: 0xFF9CD3E6, darkARGB: 0xFF2E6477),
    inBetweenFill: Color(lightARGB: 0xFFE2F1F7, darkARGB: 0xFF12313B),
    holidayDot: Color(argb: 0xFF0A7EA4),
    disabledButtonContainer: CalendarColors.disabledButtonContainer,
    disabledButtonContent: CalendarColors.disabledButtonContent)

  /// Warm orange / coral.
  static let sunset = CalendarTheme(
    ink: Color(lightARGB: 0xFFE0552B, darkARGB: 0xFFFF9166),
    onInk: Color(lightARGB: 0xFFFFFFFF, darkARGB: 0xFF2B1006),
    surface: CalendarColors.surface,
    line: CalendarColors.line,
    weekendText: CalendarColors.weekendText,
    todayRing: Color(lightARGB: 0xFFF1B49C, darkARGB: 0xFF7A4530),
    inBetweenFill: Color(lightARGB: 0xFFFBE7DD, darkARGB: 0xFF3A2018),
    holidayDot: Color(argb: 0xFFE0552B),
    disabledButtonContainer: CalendarColors.disabledButtonContainer,
    disabledButtonContent: CalendarColors.disabledButtonContent)

  /// Green.
  static let forest = CalendarTheme(
    ink: Color(lightARGB: 0xFF2E7D52, darkARGB: 0xFF63C495),
    onInk: Color(lightARGB: 0xFFFFFFFF, darkARGB: 0xFF07210F),
    surface: CalendarColors.surface,
    line: CalendarColors.line,
    weekendText: CalendarColors.weekendText,
    todayRing: Color(lightARGB: 0xFFA6D3BB, darkARGB: 0xFF356E4D),
    inBetweenFill: Color(lightARGB: 0xFFE3F1E9, darkARGB: 0xFF16301F),
    holidayDot: Color(argb: 0xFF2E7D52),
    disabledButtonContainer: CalendarColors.disabledButtonContainer,
    disabledButtonContent: CalendarColors.disabledButtonContent)

  /// Indigo / violet.
  static let midnight = CalendarTheme(
    ink: Color(lightARGB: 0xFF3A3A7A, darkARGB: 0xFF9C9AE6),
    onInk: Color(lightARGB: 0xFFFFFFFF, darkARGB: 0xFF0C0B1F),
    surface: CalendarColors.surface,
    line: CalendarColors.line,
    weekendText: CalendarColors.weekendText,
    todayRing: Color(lightARGB: 0xFFB3B3DC, darkARGB: 0xFF4A4A85),
    inBetweenFill: Color(lightARGB: 0xFFE7E7F5, darkARGB: 0xFF20203F),
    holidayDot: Color(argb: 0xFF6E6CE0),
    disabledButtonContainer: CalendarColors.disabledButtonContainer,
    disabledButtonContent: CalendarColors.disabledButtonContent)
}

/// The bundled theme palettes, with display names — handy for a theme picker / the configurator.
/// `.theme` resolves to the matching `CalendarTheme` static.
public enum CalendarThemePreset: String, CaseIterable, Sendable, Identifiable {
  case standard, ocean, sunset, forest, midnight

  public var id: String { rawValue }

  public var theme: CalendarTheme {
    switch self {
    case .standard: return .standard
    case .ocean:    return .ocean
    case .sunset:   return .sunset
    case .forest:   return .forest
    case .midnight: return .midnight
    }
  }

  public var displayName: String {
    switch self {
    case .standard: return "Standard"
    case .ocean:    return "Ocean"
    case .sunset:   return "Sunset"
    case .forest:   return "Forest"
    case .midnight: return "Midnight"
    }
  }
}
