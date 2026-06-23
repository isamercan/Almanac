import Foundation

// Timezone-stable calendar arithmetic.
// All math goes through a single Gregorian calendar with Monday as the first weekday, and
// "today" is resolved in the calendar's own time zone.

public enum CalendarMath {
  /// The default calendar for internal date math — cached (computing a `Calendar` per call is
  /// expensive and this runs on every date operation / scroll tick).
  /// `firstWeekday = 2` ⇒ Monday (Foundation: Sunday = 1 … Saturday = 7).
  public static let gregorian: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.firstWeekday = 2
    cal.timeZone = .current
    return cal
  }()

  /// Today in [calendar]'s timezone.
  public static func today(in calendar: Calendar = gregorian) -> CalDate { CalDate(Date(), in: calendar) }
}

extension CalDate {
  /// Builds a `CalDate` from a `Date`, interpreted in [calendar] (its identifier + timezone).
  init(_ date: Date, in calendar: Calendar = CalendarMath.gregorian) {
    let c = calendar.dateComponents([.year, .month, .day], from: date)
    self.init(year: c.year ?? 1970, month: c.month ?? 1, day: c.day ?? 1)
  }

  /// Start-of-day `Date` for this calendar day in [calendar].
  func startOfDay(in calendar: Calendar) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day))
      ?? Date(timeIntervalSince1970: 0)
  }

  var startOfDay: Date { startOfDay(in: CalendarMath.gregorian) }

  /// Days between two `CalDate`s in [calendar] (used by the `@SceneStorage` epoch encoding).
  func epochDay(in calendar: Calendar) -> Int {
    let epoch = CalDate(year: 1970, month: 1, day: 1).startOfDay(in: calendar)
    return calendar.dateComponents([.day], from: epoch, to: startOfDay(in: calendar)).day ?? 0
  }

  var epochDay: Int { epochDay(in: CalendarMath.gregorian) }

  init(epochDay: Int, in calendar: Calendar = CalendarMath.gregorian) {
    let epoch = CalDate(year: 1970, month: 1, day: 1).startOfDay(in: calendar)
    let date = calendar.date(byAdding: .day, value: epochDay, to: epoch) ?? epoch
    self.init(date, in: calendar)
  }

  func adding(days: Int, in calendar: Calendar = CalendarMath.gregorian) -> CalDate {
    let d = calendar.date(byAdding: .day, value: days, to: startOfDay(in: calendar)) ?? startOfDay(in: calendar)
    return CalDate(d, in: calendar)
  }
}

extension CalMonth {
  /// First day of this month, as a `Date` in [calendar] (for HorizonCalendar's `visibleDateRange`).
  func firstDayDate(in calendar: Calendar = CalendarMath.gregorian) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: 1))
      ?? Date(timeIntervalSince1970: 0)
  }

  var firstDayDate: Date { firstDayDate(in: CalendarMath.gregorian) }

  /// Last day of this month, as a `Date` in [calendar].
  func lastDayDate(in calendar: Calendar = CalendarMath.gregorian) -> Date {
    let first = firstDayDate(in: calendar)
    let range = calendar.range(of: .day, in: .month, for: first) ?? (1..<29)
    return calendar.date(from: DateComponents(year: year, month: month, day: range.upperBound - 1))
      ?? first
  }

  var lastDayDate: Date { lastDayDate(in: CalendarMath.gregorian) }

  func adding(months: Int, in calendar: Calendar = CalendarMath.gregorian) -> CalMonth {
    let d = calendar.date(byAdding: .month, value: months, to: firstDayDate(in: calendar)) ?? firstDayDate(in: calendar)
    let c = calendar.dateComponents([.year, .month], from: d)
    return CalMonth(year: c.year ?? year, month: c.month ?? month)
  }

  func adding(years: Int, in calendar: Calendar = CalendarMath.gregorian) -> CalMonth {
    adding(months: years * 12, in: calendar)
  }

  /// Clamp into `[lower, upper]`.
  func coerced(in lower: CalMonth, _ upper: CalMonth) -> CalMonth {
    if self < lower { return lower }
    if self > upper { return upper }
    return self
  }

  /// `max(self, other)`.
  func coercedAtLeast(_ other: CalMonth) -> CalMonth { self < other ? other : self }
}
