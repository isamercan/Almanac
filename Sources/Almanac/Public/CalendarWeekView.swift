import SwiftUI

/// A first-class **week** calendar: one horizontally-paged row of 7 days at a time, with the same
/// selection state machine, holidays, price badges, blocked/min-max rules, theming and accessibility
/// as the month grid — it shares `CalendarScreenViewModel` and `CalendarDayIndicator`, so behaviour
/// matches `CalendarGridView` exactly, just in a week layout.
///
/// Honours the injected `Calendar` (identifier + `firstWeekday` + timezone). Selection is reported
/// via `onSelectionChange`; pass a `CalendarController` to page programmatically (`scroll(to:)` jumps
/// to the week containing the date, `scrollToToday()` to this week).
///
///     CalendarWeekView(configuration: CalendarPickerConfiguration(localeTag: "tr", selectionMode: .single)) { result in
///       selectedDay = result.goingDate
///     }
public struct CalendarWeekView: View {
  @State private var viewModel: CalendarScreenViewModel
  private let controller: CalendarController?
  private let onSelectionChange: ((CalendarPickerResult) -> Void)?
  private let showsTitle: Bool
  private let showsWeekdayHeader: Bool

  @Environment(\.calendarStyle) private var style
  @Environment(\.calendarContent) private var content
  @State private var currentWeek: Int

  /// Sunday-of-week / first-weekday-of-week start dates, one per page.
  private let weekStarts: [CalDate]

  public init(
    configuration: CalendarPickerConfiguration,
    controller: CalendarController? = nil,
    showsTitle: Bool = true,
    showsWeekdayHeader: Bool = true,
    onSelectionChange: ((CalendarPickerResult) -> Void)? = nil)
  {
    let vm = configuration.makeViewModel()
    let calendar = vm.calendar
    let lower = CalDate(vm.startMonth.yearMonth.firstDayDate(in: calendar), in: calendar)
    let upper = CalDate(vm.endMonth.yearMonth.lastDayDate(in: calendar), in: calendar)
    let starts = WeekMath.weekStarts(from: lower, to: upper, calendar: calendar)

    _viewModel = State(initialValue: vm)
    self.controller = controller
    self.onSelectionChange = onSelectionChange
    self.showsTitle = showsTitle
    self.showsWeekdayHeader = showsWeekdayHeader
    self.weekStarts = starts

    // Open on the week containing the selection anchor (going date, else today), clamped.
    let anchor = vm.selectedRange.start ?? vm.today.date
    let index = WeekMath.index(ofWeekContaining: anchor, in: starts, calendar: calendar) ?? 0
    _currentWeek = State(initialValue: min(max(0, index), max(0, starts.count - 1)))
  }

  public var body: some View {
    VStack(spacing: 0) {
      if showsTitle { title }
      if showsWeekdayHeader { weekdayHeader }

      TabView(selection: $currentWeek) {
        ForEach(weekStarts.indices, id: \.self) { idx in
          weekRow(weekStarts[idx])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tag(idx)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .frame(height: rowHeight)
    }
    .background(style.theme.surface)
    .environment(\.layoutDirection, viewModel.isRTL ? .rightToLeft : .leftToRight)
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    .onAppear {
      controller?.scrollHandler = { date, animated in
        let target = CalDate(date, in: viewModel.calendar)
        guard let idx = WeekMath.index(ofWeekContaining: target, in: weekStarts, calendar: viewModel.calendar)
        else { return }
        if animated { withAnimation { currentWeek = idx } } else { currentWeek = idx }
      }
    }
    .onDisappear { controller?.scrollHandler = nil }
    .onChange(of: viewModel.selectedRange) { _, newValue in
      onSelectionChange?(CalendarPickerResult(range: newValue))
    }
  }

  // MARK: - Title + weekday header

  private var title: some View {
    // The month/year of the current week's midpoint (the dominant month when a week straddles two).
    let midpoint = weekStarts.indices.contains(currentWeek)
      ? weekStarts[currentWeek].adding(days: 3, in: viewModel.calendar)
      : viewModel.today.date
    return Text(CalendarFormatting.monthTitle(midpoint.calMonth, locale: viewModel.locale, calendar: viewModel.calendar))
      .calendarTextStyle(style.typography.monthTitle)
      .foregroundStyle(style.theme.ink)
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.vertical, 12)
  }

  private var weekdayHeader: some View {
    HStack(spacing: 0) {
      ForEach(0..<7, id: \.self) { column in
        let weekdayIndex = ((viewModel.calendar.firstWeekday - 1) + column) % 7   // 0 = Sun … 6 = Sat
        if let custom = content.weekdayHeader {
          custom(weekdayIndex, viewModel.locale)
        } else {
          DayOfWeekHeaderCell(
            weekdayIndex: weekdayIndex,
            locale: viewModel.locale,
            calendar: viewModel.calendar,
            style: style)
        }
      }
    }
    .padding(.horizontal, style.metrics.horizontalPadding)
    .padding(.bottom, 6)
  }

  // MARK: - Week row + day cell

  private func weekRow(_ weekStart: CalDate) -> some View {
    HStack(spacing: 0) {
      ForEach(0..<7, id: \.self) { offset in
        dayCell(weekStart.adding(days: offset, in: viewModel.calendar))
          .frame(maxWidth: .infinity)
      }
    }
    .padding(.horizontal, style.metrics.horizontalPadding)
  }

  @ViewBuilder
  private func dayCell(_ date: CalDate) -> some View {
    let state = viewModel.dayState(for: date)
    Group {
      if let custom = content.day {
        custom(viewModel.dayContext(for: date))
      } else {
        CalendarDayIndicator(
          day: date.day,
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
    .contentShape(Rectangle())
    .onTapGesture {
      if viewModel.hapticsEnabled { Haptics.dayTap() }
      viewModel.onDayTapped(date)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(accessibilityLabel(date, state))
    .accessibilityAddTraits(state.isSelected ? [.isButton, .isSelected] : .isButton)
  }

  private var rowHeight: CGFloat {
    let base = style.metrics.dayCellMaxSize + 16
    return viewModel.priceByDate.isEmpty ? base : base + 22
  }

  /// VoiceOver label: full date + selection/today/holiday state (mirrors the month grid).
  private func accessibilityLabel(_ date: CalDate, _ state: DayCellState) -> String {
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

/// Pure week-grid math, honouring the injected calendar. Extracted so paging / week boundaries are
/// unit-testable (they differ per calendar identifier + `firstWeekday`).
enum WeekMath {
  /// The first day of the week [date] falls in, for a row starting on `calendar.firstWeekday`.
  static func weekStart(of date: CalDate, calendar: Calendar) -> CalDate {
    let weekday = calendar.component(.weekday, from: date.startOfDay(in: calendar))   // 1 = Sun … 7 = Sat
    let delta = (weekday - calendar.firstWeekday + 7) % 7
    return date.adding(days: -delta, in: calendar)
  }

  /// Inclusive list of week-start dates covering `[lower, upper]`, stepping one week at a time.
  static func weekStarts(from lower: CalDate, to upper: CalDate, calendar: Calendar) -> [CalDate] {
    guard !lower.isAfter(upper) else { return [] }
    var result: [CalDate] = []
    var cursor = weekStart(of: lower, calendar: calendar)
    var guardCount = 0
    while !cursor.isAfter(upper), guardCount < 100_000 {
      result.append(cursor)
      cursor = cursor.adding(days: 7, in: calendar)
      guardCount += 1
    }
    return result
  }

  /// Index into [weekStarts] of the week containing [date], or nil if outside the range.
  static func index(ofWeekContaining date: CalDate, in weekStarts: [CalDate], calendar: Calendar) -> Int? {
    guard let first = weekStarts.first else { return nil }
    let target = weekStart(of: date, calendar: calendar)
    let idx = (target.epochDay(in: calendar) - first.epochDay(in: calendar)) / 7
    return weekStarts.indices.contains(idx) ? idx : nil
  }
}
