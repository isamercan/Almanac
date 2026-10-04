import SwiftUI
import UIKit
import HorizonCalendar

/// The scrolling month grid. backed by
/// Airbnb HorizonCalendar.
///
/// HorizonCalendar supplies only the engine: vertical months, Monday start, bounds, sticky weekday
/// header, scroll-to-month. Every day-cell visual and the tap state machine stay ours —
/// `CalendarDayIndicator` is rendered in `.days { }` and `.onDaySelection` feeds the view model.
/// HorizonCalendar's `dayRanges` (a continuous bar) is intentionally unused; the in-between look is
/// per-cell.
struct CalendarRangeSelector: View {
  @ObservedObject var viewModel: CalendarScreenViewModel
  let proxy: CalendarScrollProxy
  /// Bottom content inset so the last rows clear the floating footer.
  var bottomInset: CGFloat = 0
  /// Passed explicitly into the HorizonCalendar-hosted cells (they don't inherit the environment).
  @Environment(\.calendarStyle) private var style
  @Environment(\.calendarContent) private var content

  var body: some View {
    let calendar = viewModel.calendar
    let lower = viewModel.startMonth.yearMonth.firstDayDate(in: calendar)
    let upper = viewModel.endMonth.yearMonth.lastDayDate(in: calendar)
    let metrics = style.metrics

    let monthsLayout: MonthsLayout = viewModel.horizontalPaging
      ? .horizontal(options: HorizontalMonthsLayoutOptions())
      : .vertical(options: VerticalMonthsLayoutOptions(pinDaysOfWeekToTop: true))

    // Rebuilt on every selection change (the view model publishes it), so the day providers read
    // the current state.
    let gridContent = CalendarViewContent(
      calendar: calendar,
      visibleDateRange: lower...upper,
      monthsLayout: monthsLayout)
      .dayItemProvider { day in
        dayView(year: day.month.year, month: day.month.month, day: day.day).calendarItemModel
      }
      .dayOfWeekItemProvider { _, weekdayIndex in
        weekdayHeaderView(weekdayIndex).calendarItemModel
      }
      .monthHeaderItemProvider { month in
        monthHeaderView(CalMonth(year: month.year, month: month.month)).calendarItemModel
      }
      .dayAspectRatio(viewModel.priceByDate.isEmpty ? metrics.dayAspectRatio : metrics.dayAspectRatioWithBadges)
      .interMonthSpacing(metrics.interMonthSpacing)
      .verticalDayMargin(metrics.weekRowSpacing)
      .horizontalDayMargin(0)

    return CalendarHost(
      content: gridContent,
      backgroundColor: UIColor(style.theme.surface),
      layoutMargins: .init(top: 0, leading: metrics.horizontalPadding, bottom: bottomInset, trailing: metrics.horizontalPadding),
      proxy: proxy,
      onDaySelection: { year, month, day in
        if viewModel.hapticsEnabled { Haptics.dayTap() }
        viewModel.onDayTapped(CalDate(year: year, month: month, day: day))
      },
      onScroll: { first, last in
        viewModel.updateVisibleMonths(first: first, last: last)
      })
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    // The day grid is a fixed 7-column layout; cap Dynamic Type so day numbers don't clip.
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
  }

  @MainActor @ViewBuilder
  private func monthHeaderView(_ calMonth: CalMonth) -> some View {
    if let custom = content.monthHeader {
      custom(calMonth, viewModel.locale)
    } else {
      Text(CalendarFormatting.monthTitle(calMonth, locale: viewModel.locale, calendar: viewModel.calendar))
        .calendarTextStyle(style.typography.monthTitle)
        .foregroundStyle(style.theme.ink)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, style.metrics.monthHeaderTopPadding)
        .padding(.bottom, style.metrics.monthHeaderBottomPadding)
    }
  }

  @MainActor @ViewBuilder
  private func weekdayHeaderView(_ weekdayIndex: Int) -> some View {
    if !viewModel.showsWeekdayHeader {
      Color.clear.frame(height: 0)
    } else if let custom = content.weekdayHeader {
      custom(weekdayIndex, viewModel.locale)
    } else {
      DayOfWeekHeaderCell(weekdayIndex: weekdayIndex, locale: viewModel.locale, calendar: viewModel.calendar, style: style)
    }
  }

  @MainActor @ViewBuilder
  private func dayView(year: Int, month: Int, day: Int) -> some View {
    let date = CalDate(year: year, month: month, day: day)
    let state = viewModel.dayState(for: date)
    Group {
      if let custom = content.day {
        custom(viewModel.dayContext(for: date))
      } else {
        CalendarDayIndicator(
          day: day,
          isSelected: state.isSelected,
          isToday: state.isToday,
          isHoliday: state.holidayColor != nil,
          isInBetween: state.isInBetween,
          isSameDay: state.isSameDay,
          isDisabled: state.isDisabled,
          holidayIndicatorColor: state.holidayColor ?? .clear,
          badge: state.badge,
          style: style)
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(viewModel.accessibilityLabel(for: date))
    .accessibilityAddTraits(state.isSelected ? [.isButton, .isSelected] : .isButton)
  }
}
