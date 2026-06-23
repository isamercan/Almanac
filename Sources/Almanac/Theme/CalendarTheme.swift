import SwiftUI

/// Injectable color theme for the calendar. Defaults to `CalendarTheme.standard` (the brand
/// palette, made adaptive for dark mode). Hosts override it with `.calendarTheme(_:)`.
public struct CalendarTheme: Equatable, Sendable {
  public var ink: Color                      // primary text + selected day fill
  public var onInk: Color                    // text/rings drawn on the ink fill
  public var surface: Color                  // page + day-cell background
  public var line: Color                     // borders, dividers, disabled days
  public var weekendText: Color              // weekend day-of-week labels
  public var todayRing: Color                // outline around today
  public var inBetweenFill: Color            // in-range day fill
  public var holidayDot: Color               // default holiday indicator
  public var disabledButtonContainer: Color
  public var disabledButtonContent: Color

  public init(
    ink: Color,
    onInk: Color,
    surface: Color,
    line: Color,
    weekendText: Color,
    todayRing: Color,
    inBetweenFill: Color,
    holidayDot: Color,
    disabledButtonContainer: Color,
    disabledButtonContent: Color)
  {
    self.ink = ink
    self.onInk = onInk
    self.surface = surface
    self.line = line
    self.weekendText = weekendText
    self.todayRing = todayRing
    self.inBetweenFill = inBetweenFill
    self.holidayDot = holidayDot
    self.disabledButtonContainer = disabledButtonContainer
    self.disabledButtonContent = disabledButtonContent
  }

  /// The default palette — the brand colors, adaptive for light/dark.
  public static let standard = CalendarTheme(
    ink: CalendarColors.ink,
    onInk: CalendarColors.onInk,
    surface: CalendarColors.surface,
    line: CalendarColors.line,
    weekendText: CalendarColors.weekendText,
    todayRing: CalendarColors.todayRing,
    inBetweenFill: CalendarColors.inBetweenFill,
    holidayDot: CalendarColors.holidayDot,
    disabledButtonContainer: CalendarColors.disabledButtonContainer,
    disabledButtonContent: CalendarColors.disabledButtonContent)
}
