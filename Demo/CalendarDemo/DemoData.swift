import Foundation
import Almanac

/// Sample inputs for the demo. Builds dates relative to "now" so the picker always has selectable
/// days, plus a couple of holiday categories near the current month.
enum DemoData {
  private static var calendar: Calendar {
    var c = Calendar(identifier: .gregorian)
    c.firstWeekday = 2
    return c
  }

  static func date(daysFromNow days: Int) -> Date {
    calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: Date())) ?? Date()
  }

  /// Shared full-style date formatting for the demo screens (avoids per-screen DateFormatter setup).
  static func longDate(_ date: Date, calendar: Calendar, localeTag: String) -> String {
    let formatter = DateFormatter()
    formatter.calendar = calendar
    formatter.locale = Locale(identifier: localeTag)
    formatter.dateStyle = .full
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }

  private static func etsDate(daysFromNow days: Int) -> ETSCalendarDate {
    let d = date(daysFromNow: days)
    let c = calendar.dateComponents([.year, .month, .day], from: d)
    return ETSCalendarDate(day: c.day ?? 1, month: c.month ?? 1, year: c.year ?? 2026)
  }

  /// A couple of blocked (sold-out) days in the next two weeks.
  static func blocked() -> [Date] {
    [date(daysFromNow: 8), date(daysFromNow: 9)]
  }

  /// Sample per-day fares for the next ~45 days (cheaper on weekends, just for show).
  static func prices() -> [Date: String] {
    var result: [Date: String] = [:]
    for offset in 0..<45 {
      let d = date(daysFromNow: offset)
      let base = 950 + (offset % 7) * 120
      result[d] = "₺\(base)"
    }
    return result
  }

  static func holidays() -> [HolidayEntry] {
    [
      HolidayEntry(
        dates: [etsDate(daysFromNow: 5), etsDate(daysFromNow: 6)],
        colorARGB: 0xFF008CFF,
        description: "Resmî Tatil"),
      HolidayEntry(
        dates: [etsDate(daysFromNow: 12), etsDate(daysFromNow: 13), etsDate(daysFromNow: 14)],
        colorARGB: 0xFFE53935,
        description: "Dinî Bayram"),
      HolidayEntry(
        dates: [etsDate(daysFromNow: 33)],
        colorARGB: 0xFF43A047,
        description: "Arife"),
    ]
  }
}
