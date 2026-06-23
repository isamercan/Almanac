import SwiftUI

/// One sticky day-of-week header cell. /// short standalone weekday name, weekend labels in grey. Supplied to HorizonCalendar's
/// `.dayOfWeekHeaders` with `pinDaysOfWeekToTop`, producing a single sticky header
/// above the scrolling months.
///
/// HorizonCalendar passes `weekdayIndex` as 0 = Sunday … 6 = Saturday (calendar weekday − 1),
/// independent of the Monday-first column order, which the library handles.
struct DayOfWeekHeaderCell: View {
  let weekdayIndex: Int
  let locale: Locale
  var calendar: Calendar = CalendarMath.gregorian
  var style: CalendarStyle = .standard

  private var isWeekend: Bool { weekdayIndex == 0 || weekdayIndex == 6 } // Sunday or Saturday

  var body: some View {
    Text(CalendarFormatting.weekdayShort(weekdayIndex, locale: locale, calendar: calendar))
      .calendarTextStyle(style.typography.weekdayLabel)
      .foregroundStyle(isWeekend ? style.theme.weekendText : style.theme.ink)
      .frame(maxWidth: .infinity)
      .multilineTextAlignment(.center)
  }
}
