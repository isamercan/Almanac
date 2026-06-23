import Foundation

/// The applied selection returned to the host. The return date is forced to `nil`
/// whenever the going date is `nil`.
public struct CalendarPickerResult: Equatable, Sendable {
  public let goingDate: Date?
  public let returnDate: Date?

  public init(goingDate: Date?, returnDate: Date?) {
    self.goingDate = goingDate
    self.returnDate = goingDate == nil ? nil : returnDate
  }

  /// Builds a result from a selected range, mapping calendar days to start-of-day `Date`s.
  init(range: SelectedRange) {
    self.init(
      goingDate: range.start?.startOfDay,
      returnDate: range.end?.startOfDay)
  }
}
