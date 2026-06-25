import SwiftUI
import Observation

/// Per-day render state, computed by the view model for the day cell provider.
struct DayCellState: Equatable {
  var isSelected = false
  var isInBetween = false
  var isSameDay = false
  var isToday = false
  var isDisabled = false
  var holidayColor: Color?
  var holidayName: String?
  var badge: String?
}

/// Owns the selection state and the day-tap state machine. The screen hoists this state; the
/// per-day selection visuals live in `CalendarRangeSelector`.
@MainActor
@Observable
final class CalendarScreenViewModel {

  // MARK: Resolved inputs (parity with CalendarScreen parameters)
  let today: Today
  let startMonth: BoundaryMonth
  let endMonth: BoundaryMonth
  let firstVisibleMonth: BoundaryMonth
  let holidayDates: HolidayDays
  /// Per-day holiday names, for VoiceOver labels (parallels `holidayDates`' colors).
  let holidayNames: [CalDate: String]
  let holidaysByMonth: HolidayByMonth
  let locale: Locale
  /// `isReturn`: locks the range start so taps can only set/move the return date.
  let lockStart: Bool
  let maxSelectableDate: BoundaryDay

  // Additive feature inputs (opt-in).
  let blockedDates: Set<CalDate>
  let priceByDate: [CalDate: String]
  let minNights: Int?
  let maxNights: Int?
  let selectionMode: CalendarSelectionMode
  let horizontalPaging: Bool
  let calendar: Calendar
  let chrome: CalendarChrome
  let hapticsEnabled: Bool
  let departurePlaceholder: String?
  let returnPlaceholder: String?
  let isDismissEndEnabled: Bool
  let showPlusIconForReturn: Bool
  /// `.single` hides the return half of the top bar.
  var showsReturn: Bool { selectionMode == .range }
  var showsWeekdayHeader: Bool { chrome.showsWeekdayHeader }
  var showsLegend: Bool { chrome.showsLegend }
  /// Whether the configured locale lays out right-to-left (e.g. Arabic).
  var isRTL: Bool { locale.language.characterDirection == .rightToLeft }

  // MARK: Mutable state
  private(set) var selectedRange: SelectedRange
  /// On the departure screen the very first tap always resets to a new departure and clears the
  /// return, regardless of prior state. in `CalendarRangeSelector`.
  private var firstTap: Bool
  private(set) var visibleHolidayCategories: [HolidayCategory] = []

  init(
    today: Today,
    initialRange: SelectedRange,
    startMonth: BoundaryMonth,
    endMonth: BoundaryMonth,
    firstVisibleMonth: BoundaryMonth,
    holidayDates: HolidayDays,
    holidayNames: [CalDate: String] = [:],
    holidaysByMonth: HolidayByMonth,
    locale: Locale,
    isReturn: Bool,
    maxSelectableDate: BoundaryDay,
    blockedDates: Set<CalDate> = [],
    priceByDate: [CalDate: String] = [:],
    minNights: Int? = nil,
    maxNights: Int? = nil,
    selectionMode: CalendarSelectionMode = .range,
    horizontalPaging: Bool = false,
    calendar: Calendar = CalendarMath.gregorian,
    chrome: CalendarChrome = .full,
    hapticsEnabled: Bool = true,
    departurePlaceholder: String? = nil,
    returnPlaceholder: String? = nil,
    isDismissEndEnabled: Bool = true,
    showPlusIconForReturn: Bool = true)
  {
    self.today = today
    self.selectedRange = initialRange
    self.startMonth = startMonth
    self.endMonth = endMonth
    self.firstVisibleMonth = firstVisibleMonth
    self.holidayDates = holidayDates
    self.holidayNames = holidayNames
    self.holidaysByMonth = holidaysByMonth
    self.locale = locale
    self.lockStart = isReturn
    self.maxSelectableDate = maxSelectableDate
    self.blockedDates = blockedDates
    self.priceByDate = priceByDate
    self.minNights = minNights
    self.maxNights = maxNights
    self.selectionMode = selectionMode
    self.horizontalPaging = horizontalPaging
    self.calendar = calendar
    self.chrome = chrome
    self.hapticsEnabled = hapticsEnabled
    self.departurePlaceholder = departurePlaceholder
    self.returnPlaceholder = returnPlaceholder
    self.isDismissEndEnabled = isDismissEndEnabled
    self.showPlusIconForReturn = showPlusIconForReturn
    self.firstTap = !isReturn
    // Seed the legend for the initially visible month; refined by `updateVisibleMonths` on scroll.
    updateVisibleMonths(first: firstVisibleMonth.yearMonth, last: firstVisibleMonth.yearMonth)
  }

  /// Restores a previously-persisted selection (state restoration / process death). Consumes the
  /// pending `firstTap` so a restored range is not wiped by the next tap behaving like a first tap.
  func restore(_ range: SelectedRange) {
    selectedRange = range
    firstTap = false
  }

  // MARK: - Tap state machine (port of CalendarRangeSelector.onDayClicked)

  /// `true` when [date] may be tapped: not before today and not after the max selectable date.
  /// (HorizonCalendar only vends in-month days, so the `DayPosition.MonthDate` check is implicit.)
  func isSelectable(_ date: CalDate) -> Bool {
    if date.isBefore(today.date) { return false }
    if let max = maxSelectableDate.date, date.isAfter(max) { return false }
    if blockedDates.contains(date) { return false }
    return true
  }

  /// Whether `start…end` is a valid closed range: honours min/max nights and spans no blocked day.
  private func isValidEnd(start: CalDate, end: CalDate) -> Bool {
    let nights = end.epochDay - start.epochDay
    if let minN = minNights, nights < minN { return false }
    if let maxN = maxNights, nights > maxN { return false }
    if !blockedDates.isEmpty, blockedDates.contains(where: { $0.isAfter(start) && $0.isBefore(end) }) {
      return false
    }
    return true
  }

  func onDayTapped(_ date: CalDate) {
    guard isSelectable(date) else { return }

    // Single-date mode: every tap selects exactly one day.
    if selectionMode == .single {
      firstTap = false
      if selectedRange != SelectedRange(start: date) { selectedRange = SelectedRange(start: date) }
      return
    }

    let current = selectedRange
    let lockedStart = current.start
    let next: SelectedRange

    if firstTap {
      // First tap on the departure screen: always reset to the new departure, clear the return.
      firstTap = false
      next = SelectedRange(start: date)
    } else if lockStart, let locked = lockedStart {
      // Start is locked: only ever move the end (when valid), never the start. Taps before the
      // locked start, or that violate min/max nights / span a blocked day, are ignored.
      next = (!date.isBefore(locked) && isValidEnd(start: locked, end: date))
        ? current.with(end: date) : current
    } else if current.isPartial, let s = current.start, !date.isBefore(s) {
      // Closing an open range — only when the end is valid; otherwise keep the open range so the
      // user can pick a different end.
      next = isValidEnd(start: s, end: date) ? current.with(end: date) : current
    } else {
      // No range, completed range, or end picked before start → start fresh.
      next = SelectedRange(start: date)
    }

    if next != current {
      selectedRange = next
    }
  }

  /// Composes the VoiceOver label for [date]: full localized date + selection / today / holiday
  /// state. Shared by every day-cell surface (month grid + week strip) so their wording stays in sync.
  func accessibilityLabel(for date: CalDate) -> String {
    let state = dayState(for: date)
    var parts = [CalendarFormatting.longDate(date, locale: locale, calendar: calendar)]
    if state.isToday { parts.append(L10n.string(L10n.Key.a11yToday, locale: locale)) }

    let range = selectedRange
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

  // MARK: - Per-day render state (port of RangeDayCell)

  func dayState(for date: CalDate) -> DayCellState {
    let r = selectedRange
    let minDate: CalDate? = lockStart ? r.start : nil
    let maxDate = maxSelectableDate.date

    var isDisabled = date.isBefore(today.date)
    if let minDate, date.isBefore(minDate) { isDisabled = true }
    if let maxDate, date.isAfter(maxDate) { isDisabled = true }
    if blockedDates.contains(date) { isDisabled = true }

    let isSameDay = r.isComplete && r.start == r.end && r.start == date

    return DayCellState(
      isSelected: r.isEndpoint(date),
      isInBetween: r.isInBetween(date),
      isSameDay: isSameDay,
      isToday: date == today.date,
      isDisabled: isDisabled,
      holidayColor: holidayDates.dates[date],
      holidayName: holidayNames[date],
      badge: priceByDate[date])
  }

  /// Public, render-ready context for a day — fed to a custom `.calendarDay { … }` content closure.
  func dayContext(for date: CalDate) -> CalendarDayContext {
    let state = dayState(for: date)
    let range = selectedRange
    return CalendarDayContext(
      date: date.startOfDay,
      day: date.day,
      month: date.month,
      year: date.year,
      isToday: state.isToday,
      isSelected: state.isSelected,
      isRangeStart: date == range.start,
      isRangeEnd: date == range.end,
      isInBetween: state.isInBetween,
      isSameDay: state.isSameDay,
      isDisabled: state.isDisabled,
      isBlocked: blockedDates.contains(date),
      isCurrentMonth: true,
      holidayColor: state.holidayColor,
      holidayName: state.holidayName,
      badge: state.badge)
  }

  // MARK: - Footer / top-bar actions (port of CalendarScreen callbacks)

  /// Whether the "Clear" button is enabled.
  var clearEnabled: Bool { lockStart ? selectedRange.end != nil : selectedRange.start != nil }
  /// Whether the "Apply" button is enabled.
  var applyEnabled: Bool { selectedRange.start != nil }

  /// Footer "Clear": on the return screen only the end is cleared; otherwise the whole range.
  func clear() {
    selectedRange = lockStart ? selectedRange.with(end: nil) : SelectedRange()
  }

  /// Top-bar return-date dismiss.
  func clearReturn() {
    selectedRange = selectedRange.with(end: nil)
  }

  // MARK: - Legend (port of CalendarScreen's snapshotFlow → visibleHolidayCategories)

  /// Recomputes the legend for the currently visible months, distinct by description and ordered
  /// by earliest date — the holiday-by-month mapping.
  func updateVisibleMonths(first: CalMonth, last: CalMonth) {
    guard first <= last else { return }
    var months: [CalMonth] = []
    var cursor = first
    while cursor <= last {
      months.append(cursor)
      cursor = cursor.adding(months: 1)
    }

    var seenDescriptions = Set<String>()
    var categories: [HolidayCategory] = []
    for month in months {
      let entries = holidaysByMonth.holidaysByMonth[BoundaryMonth(month)] ?? []
      for entry in entries where !seenDescriptions.contains(entry.description) {
        seenDescriptions.insert(entry.description)
        let sortKey = entry.dates.map { $0.calDate.sortKey }.min() ?? 0
        categories.append(
          HolidayCategory(
            color: Color(argb: entry.colorARGB),
            categoryDescription: entry.description,
            sortKey: sortKey))
      }
    }
    visibleHolidayCategories = categories.sorted { $0.sortKey < $1.sortKey }
  }
}
