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
  let viewModel: CalendarScreenViewModel
  let proxy: CalendarViewProxy
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

    return CalendarViewRepresentable(
      calendar: calendar,
      visibleDateRange: lower...upper,
      monthsLayout: monthsLayout,
      // Re-renders the day providers whenever the selection changes (the recommended pattern in
      // place of reading mutable state inside the provider closures).
      dataDependency: viewModel.selectedRange,
      proxy: proxy)
    .days { day in
      dayView(for: day)
    }
    .dayOfWeekHeaders { _, weekdayIndex in
      weekdayHeaderView(weekdayIndex)
    }
    .monthHeaders { month in
      let calMonth = CalMonth(year: month.year, month: month.month)
      if let custom = content.monthHeader {
        custom(calMonth, viewModel.locale)
      } else {
        Text(CalendarFormatting.monthTitle(calMonth, locale: viewModel.locale, calendar: calendar))
          .calendarTextStyle(style.typography.monthTitle)
          .foregroundStyle(style.theme.ink)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.top, metrics.monthHeaderTopPadding)
          .padding(.bottom, metrics.monthHeaderBottomPadding)
      }
    }
    .dayAspectRatio(viewModel.priceByDate.isEmpty ? metrics.dayAspectRatio : metrics.dayAspectRatioWithBadges)
    .interMonthSpacing(metrics.interMonthSpacing)
    .verticalDayMargin(metrics.weekRowSpacing)
    .horizontalDayMargin(0)
    .backgroundColor(UIColor(style.theme.surface))
    .layoutMargins(
      .init(top: 0, leading: metrics.horizontalPadding, bottom: bottomInset, trailing: metrics.horizontalPadding))
    .onDaySelection { day in
      if viewModel.hapticsEnabled { Haptics.dayTap() }
      viewModel.onDayTapped(CalDate(year: day.month.year, month: day.month.month, day: day.day))
    }
    .onScroll { visibleDayRange, _ in
      let lowerMonth = visibleDayRange.lowerBound.month
      let upperMonth = visibleDayRange.upperBound.month
      viewModel.updateVisibleMonths(
        first: CalMonth(year: lowerMonth.year, month: lowerMonth.month),
        last: CalMonth(year: upperMonth.year, month: upperMonth.month))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    // The day grid is a fixed 7-column layout; cap Dynamic Type so day numbers don't clip.
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
  }

  @ViewBuilder
  private func weekdayHeaderView(_ weekdayIndex: Int) -> some View {
    if !viewModel.showsWeekdayHeader {
      Color.clear.frame(height: 0)
    } else if let custom = content.weekdayHeader {
      custom(weekdayIndex, viewModel.locale)
    } else {
      DayOfWeekHeaderCell(weekdayIndex: weekdayIndex, locale: viewModel.locale, calendar: viewModel.calendar, style: style)
    }
  }

  @ViewBuilder
  private func dayView(for day: DayComponents) -> some View {
    let date = CalDate(year: day.month.year, month: day.month.month, day: day.day)
    let state = viewModel.dayState(for: date)
    Group {
      if let custom = content.day {
        custom(viewModel.dayContext(for: date))
      } else {
        CalendarDayIndicator(
          day: day.day,
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
    .accessibilityLabel(accessibilityLabel(date: date, state: state))
    .accessibilityAddTraits(state.isSelected ? [.isButton, .isSelected] : .isButton)
  }

  /// Composes a VoiceOver label: full date + selection/today/holiday state.
  private func accessibilityLabel(date: CalDate, state: DayCellState) -> String {
    let locale = viewModel.locale
    var parts = [CalendarFormatting.longDate(date, locale: locale, calendar: viewModel.calendar)]
    if state.isToday { parts.append(L10n.string(L10n.Key.a11yToday, locale: locale)) }

    let range = viewModel.selectedRange
    if state.isDisabled {
      parts.append(L10n.string(L10n.Key.a11yUnavailable, locale: locale))
    } else if state.isSameDay {
      parts.append(L10n.string(L10n.Key.a11ySelectedSingle, locale: locale))
    } else if date == range.start {
      parts.append(L10n.string(L10n.Key.a11ySelectedStart, locale: locale))
    } else if date == range.end {
      parts.append(L10n.string(L10n.Key.a11ySelectedEnd, locale: locale))
    } else if state.isInBetween {
      parts.append(L10n.string(L10n.Key.a11yInRange, locale: locale))
    }

    if let name = state.holidayName { parts.append(name) }
    return parts.joined(separator: ", ")
  }
}
