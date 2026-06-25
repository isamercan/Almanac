import Foundation

// Locale-aware date text built with `DateFormatter`:
//  • month title  ← standalone full month name + year
//  • weekday short ← short weekday symbol
//  • long date    ← localized long date style
// Each capitalizes the first character per-locale.
//
// `DateFormatter` creation is expensive and these run per-day (VoiceOver labels) / per-month while
// scrolling, so formatters are cached (keyed by locale + calendar + kind). `NSCache` is thread-safe;
// configured formatters are only read afterwards, which is safe for concurrent use.

enum CalendarFormatting {
  private static let cache = NSCache<NSString, DateFormatter>()

  private static func formatter(
    locale: Locale,
    calendar: Calendar,
    key: String,
    configure: (DateFormatter) -> Void) -> DateFormatter
  {
    let cacheKey = "\(locale.identifier)|\(calendar.identifier)|\(key)" as NSString
    if let cached = cache.object(forKey: cacheKey) { return cached }
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.calendar = calendar
    configure(formatter)
    cache.setObject(formatter, forKey: cacheKey)
    return formatter
  }

  /// "Mayıs 2026" / "May 2026" — standalone full month name + year, first char uppercased.
  static func monthTitle(_ month: CalMonth, locale: Locale, calendar: Calendar = CalendarMath.gregorian) -> String {
    let symbols = formatter(locale: locale, calendar: calendar, key: "symbols") { _ in }.standaloneMonthSymbols ?? []
    let index = month.month - 1
    let name = (symbols.indices.contains(index) ? symbols[index] : "").capitalizedFirst(locale)
    return "\(name) \(month.year)"
  }

  /// "2026" / "١٤٤٧" — the era-aware, localized year number for [year] in [calendar]. Renders the
  /// correct numerals per locale and the right era year for non-Gregorian calendars (e.g. Hijri).
  static func yearTitle(_ year: Int, locale: Locale, calendar: Calendar = CalendarMath.gregorian) -> String {
    let formatter = formatter(locale: locale, calendar: calendar, key: "year") {
      $0.setLocalizedDateFormatFromTemplate("y")
    }
    return formatter.string(from: CalMonth(year: year, month: 1).firstDayDate(in: calendar))
  }

  /// "Mayıs" / "May" — standalone full month name (no year), first char uppercased.
  static func monthName(_ month: Int, locale: Locale, calendar: Calendar = CalendarMath.gregorian) -> String {
    let symbols = formatter(locale: locale, calendar: calendar, key: "symbols") { _ in }.standaloneMonthSymbols ?? []
    let index = month - 1
    return (symbols.indices.contains(index) ? symbols[index] : "").capitalizedFirst(locale)
  }

  /// "Pzt" / "Mon" — short standalone weekday for [weekdayIndex] (0 = Sunday … 6 = Saturday).
  static func weekdayShort(_ weekdayIndex: Int, locale: Locale, calendar: Calendar = CalendarMath.gregorian) -> String {
    let symbols = formatter(locale: locale, calendar: calendar, key: "symbols") { _ in }.shortStandaloneWeekdaySymbols ?? []
    guard symbols.indices.contains(weekdayIndex) else { return "" }
    return symbols[weekdayIndex].capitalizedFirst(locale)
  }

  /// Localized long date, e.g. "9 Mayıs 2026" / "May 9, 2026".
  static func longDate(_ date: CalDate, locale: Locale, calendar: Calendar = CalendarMath.gregorian) -> String {
    let formatter = formatter(locale: locale, calendar: calendar, key: "long") {
      $0.dateStyle = .long
      $0.timeStyle = .none
    }
    return formatter.string(from: date.startOfDay(in: calendar))
  }
}

extension String {
  /// Uppercases only the first character, locale-aware.
  func capitalizedFirst(_ locale: Locale) -> String {
    guard let first = first else { return self }
    return String(first).uppercased(with: locale) + dropFirst()
  }
}
