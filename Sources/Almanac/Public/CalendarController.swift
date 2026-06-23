import Foundation

/// Programmatic control of a presented calendar. Create one, pass it to `CalendarRangePickerView`,
/// and call `scroll(to:)` to move the calendar to a given date.
///
///     @StateObject private var controller = CalendarController()
///     CalendarRangePickerView(configuration: cfg, controller: controller, onApply: …)
///     // later: controller.scroll(to: someDate)
@MainActor
public final class CalendarController: ObservableObject {
  public init() {}

  /// Wired by the calendar view while it is on screen.
  var scrollHandler: ((_ date: Date, _ animated: Bool) -> Void)?

  /// Scrolls the calendar so the month containing [date] is at the top (vertical) / leading
  /// (horizontal) edge. No-op if the calendar isn't currently presented.
  public func scroll(to date: Date, animated: Bool = true) {
    scrollHandler?(date, animated)
  }

  /// Scrolls to the month containing today (clamped into the visible range).
  public func scrollToToday(animated: Bool = true) {
    scroll(to: Date(), animated: animated)
  }
}
