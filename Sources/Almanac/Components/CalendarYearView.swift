import SwiftUI

/// A compact month-grid year overview (TimePage / ElegantCalendar-style). Renders one **or many**
/// years as scrollable 12-month overviews; tapping a month invokes `onSelectMonth` — e.g. to jump a
/// range picker (via `CalendarController.scroll(to:)`) to that month.
///
/// All date math honours the injected `calendar` (identifier + `firstWeekday` + timezone), so a
/// non-Gregorian calendar (e.g. Hijri) lays out its blanks, day counts, month names and year titles
/// correctly. Pure SwiftUI; no HorizonCalendar dependency.
///
///     // one year
///     CalendarYearView(year: 2026, locale: .init(identifier: "tr")) { month in /* jump */ }
///     // a span of years, scrollable
///     CalendarYearView(years: 2026...2028, calendar: cal, locale: .current) { month in /* jump */ }
public struct CalendarYearView: View {
  private let years: [Int]
  private let calendar: Calendar
  private let locale: Locale
  private let onSelectMonth: (CalMonth) -> Void

  @Environment(\.calendarStyle) private var style

  /// A single year.
  public init(
    year: Int,
    calendar: Calendar = CalendarMath.gregorian,
    locale: Locale = .current,
    onSelectMonth: @escaping (CalMonth) -> Void = { _ in })
  {
    self.years = [year]
    self.calendar = calendar
    self.locale = locale
    self.onSelectMonth = onSelectMonth
  }

  /// A span of years, scrolled vertically. Each year is a titled 12-month section.
  public init(
    years: ClosedRange<Int>,
    calendar: Calendar = CalendarMath.gregorian,
    locale: Locale = .current,
    onSelectMonth: @escaping (CalMonth) -> Void = { _ in })
  {
    self.years = Array(years)
    self.calendar = calendar
    self.locale = locale
    self.onSelectMonth = onSelectMonth
  }

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
  private var showsYearTitles: Bool { years.count > 1 }

  public var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 28) {
        ForEach(years, id: \.self) { year in
          VStack(alignment: .leading, spacing: 16) {
            if showsYearTitles {
              Text(CalendarFormatting.yearTitle(year, locale: locale, calendar: calendar))
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(style.theme.ink)
            }
            LazyVGrid(columns: columns, spacing: 20) {
              ForEach(1...12, id: \.self) { month in
                let calMonth = CalMonth(year: year, month: month)
                MiniMonthView(month: calMonth, locale: locale, calendar: calendar, theme: style.theme)
                  .contentShape(Rectangle())
                  .onTapGesture { onSelectMonth(calMonth) }
                  .accessibilityElement(children: .combine)
                  .accessibilityAddTraits(.isButton)
              }
            }
          }
        }
      }
      .padding()
    }
    .background(style.theme.surface)
  }
}

/// Pure mini-month grid math, honouring the injected calendar. Extracted so the blank-cell offset
/// and day count (which differ per calendar identifier + `firstWeekday`) are unit-testable.
enum YearGridMath {
  /// Number of empty leading cells before day 1, for a 7-column grid starting on `calendar.firstWeekday`.
  static func leadingBlanks(for month: CalMonth, calendar: Calendar) -> Int {
    let weekday = calendar.component(.weekday, from: month.firstDayDate(in: calendar))   // 1 = Sun … 7 = Sat
    return (weekday - calendar.firstWeekday + 7) % 7
  }

  /// Days in the month (29/30 for Hijri, 28–31 for Gregorian).
  static func dayCount(for month: CalMonth, calendar: Calendar) -> Int {
    calendar.range(of: .day, in: .month, for: month.firstDayDate(in: calendar))?.count ?? 30
  }
}

/// One small month grid: title + first-weekday-aware 7-column day numbers, using the injected
/// `calendar` for all math (blanks, day count, month name).
private struct MiniMonthView: View {
  let month: CalMonth
  let locale: Locale
  let calendar: Calendar
  let theme: CalendarTheme

  private var leadingBlanks: Int { YearGridMath.leadingBlanks(for: month, calendar: calendar) }
  private var dayCount: Int { YearGridMath.dayCount(for: month, calendar: calendar) }

  private let grid = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)

  var body: some View {
    VStack(spacing: 6) {
      Text(CalendarFormatting.monthName(month.month, locale: locale, calendar: calendar))
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(theme.ink)
        .frame(maxWidth: .infinity, alignment: .leading)

      LazyVGrid(columns: grid, spacing: 2) {
        ForEach(0..<leadingBlanks, id: \.self) { _ in Color.clear.frame(height: 14) }
        ForEach(1...dayCount, id: \.self) { day in
          Text("\(day)")
            .font(.system(size: 9))
            .foregroundStyle(theme.ink.opacity(0.8))
            .frame(maxWidth: .infinity, minHeight: 14)
        }
      }
    }
  }
}

#Preview("Single year") {
  CalendarYearView(year: 2026, locale: Locale(identifier: "tr"))
}

#Preview("Multi-year") {
  CalendarYearView(years: 2026...2028, locale: Locale(identifier: "en"))
}
