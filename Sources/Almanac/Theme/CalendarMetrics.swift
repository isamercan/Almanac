import CoreGraphics

/// Numeric design tokens for the calendar. Every default equals the original hardcoded value, so
/// `.standard` reproduces the stock look exactly; override any field to restyle.
public struct CalendarMetrics: Equatable, Sendable {

  // MARK: Day cell
  /// Shape of the selection fill / today ring / same-day ring. Default `.circle`.
  public var daySelectionShape: CalendarDayShape = .circle
  /// Min/max size of the day's selection square (36.48 pt).
  public var dayCellMinSize: CGFloat = 36
  public var dayCellMaxSize: CGFloat = 48
  /// Duration of the select / in-between circle scale animation.
  public var selectionAnimationDuration: Double = 0.3
  public var todayRingWidth: CGFloat = 2
  public var sameDayRingWidth: CGFloat = 4
  public var holidayDotSize: CGFloat = 4
  public var holidayDotBottomPadding: CGFloat = 8
  public var badgeFontSize: CGFloat = 9

  // MARK: Month grid layout
  public var horizontalPadding: CGFloat = 6        // CalendarHorizontalPadding
  public var weekRowSpacing: CGFloat = 8           // vertical day margin
  public var interMonthSpacing: CGFloat = 0
  public var dayAspectRatio: CGFloat = 1
  public var dayAspectRatioWithBadges: CGFloat = 0.72
  public var monthHeaderTopPadding: CGFloat = 24
  public var monthHeaderBottomPadding: CGFloat = 8

  // MARK: Top bar
  public var topBarHeight: CGFloat = 56
  public var topBarHorizontalPadding: CGFloat = 16
  public var dateRowVerticalPadding: CGFloat = 24
  public var dividerHeight: CGFloat = 1
  /// Drum/odometer flip duration for the departure/return labels.
  public var dateFlipDuration: Double = 0.4

  // MARK: Footer
  public var footerCornerRadius: CGFloat = 24
  public var footerShadowRadius: CGFloat = 12
  public var footerHorizontalPadding: CGFloat = 20
  public var footerVerticalPadding: CGFloat = 16
  public var footerContentSpacing: CGFloat = 16    // gap between legend and buttons
  public var buttonHeight: CGFloat = 48
  public var buttonSpacing: CGFloat = 12
  public var buttonBorderWidth: CGFloat = 1
  public var legendDotSize: CGFloat = 8
  public var legendItemSpacing: CGFloat = 4

  public init() {}
}
