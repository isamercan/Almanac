import Foundation

/// Toggles the visibility of each surrounding UI part of the picker, independently. `.full` is the
/// stock picker; `.none` is just the scrolling grid. Mix freely (e.g. grid + Apply button only).
public struct CalendarChrome: Equatable, Sendable {
  /// The title row: back / "Select Date" / close, plus its divider.
  public var showsTitleBar: Bool
  /// The departure → return summary row.
  public var showsDateRow: Bool
  /// The sticky day-of-week header row.
  public var showsWeekdayHeader: Bool
  /// The footer holiday legend.
  public var showsLegend: Bool
  /// The bottom footer panel (legend + buttons). When false, no footer is shown at all.
  public var showsFooter: Bool
  /// The "Clear" button (within the footer).
  public var showsClearButton: Bool
  /// The "Apply" button (within the footer).
  public var showsApplyButton: Bool

  public init(
    showsTitleBar: Bool = true,
    showsDateRow: Bool = true,
    showsWeekdayHeader: Bool = true,
    showsLegend: Bool = true,
    showsFooter: Bool = true,
    showsClearButton: Bool = true,
    showsApplyButton: Bool = true)
  {
    self.showsTitleBar = showsTitleBar
    self.showsDateRow = showsDateRow
    self.showsWeekdayHeader = showsWeekdayHeader
    self.showsLegend = showsLegend
    self.showsFooter = showsFooter
    self.showsClearButton = showsClearButton
    self.showsApplyButton = showsApplyButton
  }

  /// The stock picker — every part visible.
  public static let full = CalendarChrome()

  /// No top bar and no footer (the bare grid look); the weekday header is kept.
  public static let none = CalendarChrome(
    showsTitleBar: false, showsDateRow: false, showsWeekdayHeader: true, showsLegend: false,
    showsFooter: false, showsClearButton: false, showsApplyButton: false)

  /// `showsTopBar` convenience: true when either the title bar or the date row is shown.
  public var showsTopBar: Bool { showsTitleBar || showsDateRow }
}
