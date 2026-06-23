import SwiftUI
import Almanac

// Shared building blocks for the "Calendar Library" example gallery — a SwiftUI re-creation of the
// kizitonwose Calendar sample screens (calendar.kizitonwose.dev), built entirely on Almanac's
// public API. Where a pattern isn't a built-in Almanac mode (week calendars), it is a small
// SwiftUI view themed with Almanac's design tokens so the look stays consistent.

/// A caption banner shown at the top of each example, describing what it demonstrates.
struct ExampleCaption: View {
  let text: String
  init(_ text: String) { self.text = text }
  var body: some View {
    Text(text)
      .font(.footnote)
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(Color(.secondarySystemBackground))
  }
}

/// Sample inputs used across the example gallery.
enum ExampleData {
  static var calendar: Calendar {
    var c = Calendar(identifier: .gregorian)
    c.firstWeekday = 2          // Monday
    c.timeZone = .current
    return c
  }

  /// `n` consecutive days starting today.
  static func upcomingDays(_ n: Int) -> [Date] {
    let start = calendar.startOfDay(for: Date())
    return (0..<n).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
  }

  /// The Monday of the current week, then the following `weeks - 1` Mondays.
  static func mondays(_ weeks: Int) -> [Date] {
    let today = calendar.startOfDay(for: Date())
    let weekday = calendar.component(.weekday, from: today)         // 1 = Sun … 7 = Sat
    let backToMonday = (weekday - calendar.firstWeekday + 7) % 7
    guard let thisMonday = calendar.date(byAdding: .day, value: -backToMonday, to: today) else { return [] }
    return (0..<weeks).compactMap { calendar.date(byAdding: .day, value: $0 * 7, to: thisMonday) }
  }

  /// Deterministic 0…1 "activity" level for a day (drives the heat-map example).
  static func heat(for date: Date) -> Double {
    let doy = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
    let bucket = (doy * 37 + 11) % 5            // 0…4
    return Double(bucket) / 4.0
  }
}

func exIsSameDay(_ a: Date?, _ b: Date?) -> Bool {
  guard let a, let b else { return false }
  return ExampleData.calendar.isDate(a, inSameDayAs: b)
}

func exIsToday(_ date: Date) -> Bool { ExampleData.calendar.isDateInToday(date) }

/// One day cell for the week-calendar examples: weekday letter + day number, circular selection.
/// Styled with Almanac's `CalendarTheme.standard` tokens so it matches the month views.
struct WeekDayCell: View {
  let date: Date
  let isSelected: Bool
  let isToday: Bool
  var width: CGFloat = 46

  private let theme = CalendarTheme.standard

  var body: some View {
    let day = ExampleData.calendar.component(.day, from: date)
    VStack(spacing: 6) {
      Text(Self.weekdaySymbol(date))
        .font(.caption2.weight(.medium))
        .foregroundStyle(.secondary)
      Text("\(day)")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(isSelected ? theme.onInk : theme.ink)
        .frame(width: 38, height: 38)
        .background(isSelected ? theme.ink : Color.clear, in: Circle())
        .overlay(
          Circle().strokeBorder(theme.todayRing, lineWidth: (isToday && !isSelected) ? 2 : 0))
    }
    .frame(width: width)
    .contentShape(Rectangle())
  }

  private static let wdFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "tr")
    f.dateFormat = "EEE"
    return f
  }()
  static func weekdaySymbol(_ date: Date) -> String {
    wdFormatter.string(from: date).uppercased()
  }
}

/// A footer line echoing the currently-selected day for the week / toggle examples.
struct SelectionLabel: View {
  let date: Date?
  private static let formatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .full
    f.locale = Locale(identifier: "tr")
    return f
  }()
  var body: some View {
    Text(date.map { "Seçildi: " + Self.formatter.string(from: $0) } ?? "Bir gün seçin")
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
  }
}

/// Formats a `CalMonth` (Almanac's month value type) as e.g. "Haziran 2026".
func exMonthTitle(_ month: CalMonth, locale: Locale) -> String {
  var comps = DateComponents()
  comps.year = month.year
  comps.month = month.month
  comps.day = 1
  let date = ExampleData.calendar.date(from: comps) ?? Date()
  let f = DateFormatter()
  f.locale = locale
  f.dateFormat = "LLLL yyyy"
  return f.string(from: date).capitalized
}
