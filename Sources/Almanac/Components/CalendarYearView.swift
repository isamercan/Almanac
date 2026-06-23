import SwiftUI

/// A compact 12-month overview for a single year (OBCalendar-style year view). Tapping a month
/// invokes `onSelectMonth` — e.g. to jump the range picker (via `CalendarController.scroll(to:)`)
/// to that month. Pure SwiftUI; uses `CalDate` math (no HorizonCalendar dependency).
public struct CalendarYearView: View {
  private let year: Int
  private let locale: Locale
  private let onSelectMonth: (CalMonth) -> Void

  @Environment(\.calendarStyle) private var style

  public init(
    year: Int,
    locale: Locale = .current,
    onSelectMonth: @escaping (CalMonth) -> Void = { _ in })
  {
    self.year = year
    self.locale = locale
    self.onSelectMonth = onSelectMonth
  }

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

  public var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 20) {
        ForEach(1...12, id: \.self) { month in
          let calMonth = CalMonth(year: year, month: month)
          MiniMonthView(month: calMonth, locale: locale, theme: style.theme)
            .contentShape(Rectangle())
            .onTapGesture { onSelectMonth(calMonth) }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
        }
      }
      .padding()
    }
    .background(style.theme.surface)
  }
}

/// One small month grid: title + Monday-first 7-column day numbers.
private struct MiniMonthView: View {
  let month: CalMonth
  let locale: Locale
  let theme: CalendarTheme

  private var leadingBlanks: Int {
    let cal = CalendarMath.gregorian
    let weekday = cal.component(.weekday, from: month.firstDayDate)   // 1 = Sun … 7 = Sat
    return (weekday - cal.firstWeekday + 7) % 7
  }

  private var dayCount: Int {
    CalendarMath.gregorian.range(of: .day, in: .month, for: month.firstDayDate)?.count ?? 30
  }

  private let grid = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)

  var body: some View {
    VStack(spacing: 6) {
      Text(CalendarFormatting.monthName(month.month, locale: locale))
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

#Preview {
  CalendarYearView(year: 2026, locale: Locale(identifier: "tr"))
}
