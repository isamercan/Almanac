import SwiftUI

/// How taps build a selection. `.range` is the default; `.single` picks one day.
public enum CalendarSelectionMode: Sendable {
  case range
  case single
}

/// Host-facing input for the calendar. `makeViewModel()` resolves today, the month bounds, the
/// selection anchor, holiday maps and locale from these values.
public struct CalendarPickerConfiguration {
  /// Range start (departure / check-in / pick-up).
  public var goingDate: Date?
  /// Range end (return / check-out / drop-off).
  public var returnDate: Date?
  /// Locks the start so only the return date can be set/moved.
  public var isReturn: Bool
  /// Inclusive last selectable day; also caps the visible month range.
  public var maxSelectableDate: Date?
  /// Holiday categories + their days.
  public var holidays: [HolidayEntry]
  /// BCP-47 language tag (e.g. "tr", "en-US"); nil ⇒ system default.
  public var localeTag: String?
  /// Opt-in state restoration: when set, the in-progress selection is persisted via `@SceneStorage`
  /// under this key and restored after process death. nil ⇒ no persistence (default).
  public var restorationID: String?

  // MARK: Additive features (opt-in; defaults preserve the standard behaviour)

  /// Specific unavailable days that cannot be tapped, and which a range may not span.
  public var blockedDates: [Date]
  /// Optional short per-day badge text (e.g. a fare like "₺1.250"). Non-empty ⇒ taller day cells.
  public var priceByDate: [Date: String]
  /// Minimum nights between start and end (inclusive lower bound on `end − start` in days).
  public var minNights: Int?
  /// Maximum nights between start and end.
  public var maxNights: Int?
  /// `.range` (default) or `.single`-day selection.
  public var selectionMode: CalendarSelectionMode
  /// When true, months scroll horizontally with monthly paging instead of vertically.
  public var horizontalPaging: Bool
  /// The calendar system + first weekday + timezone used for all date math and display. Inject a
  /// non-Gregorian calendar (e.g. `Calendar(identifier: .islamicUmmAlQura)`) or a fixed timezone
  /// here. Default: Gregorian, Monday-first, current timezone.
  public var calendar: Calendar
  /// Per-part visibility of the surrounding UI (top bar, footer, buttons, header, legend). Default `.full`.
  public var chrome: CalendarChrome
  /// Whether a haptic fires on day taps. Default true.
  public var hapticsEnabled: Bool
  /// Top-bar placeholder titles (e.g. hotel check-in/out). nil ⇒ departure / add-return defaults.
  public var departurePlaceholder: String?
  public var returnPlaceholder: String?
  /// Whether the return date shows a clear (✕) affordance. (Default: true.)
  public var isDismissEndEnabled: Bool
  /// Whether the empty return shows a "+" icon. (Default: true.)
  public var showPlusIconForReturn: Bool

  public init(
    goingDate: Date? = nil,
    returnDate: Date? = nil,
    isReturn: Bool = false,
    maxSelectableDate: Date? = nil,
    holidays: [HolidayEntry] = [],
    localeTag: String? = nil,
    restorationID: String? = nil,
    blockedDates: [Date] = [],
    priceByDate: [Date: String] = [:],
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
    self.goingDate = goingDate
    self.returnDate = returnDate
    self.isReturn = isReturn
    self.maxSelectableDate = maxSelectableDate
    self.holidays = holidays
    self.localeTag = localeTag
    self.restorationID = restorationID
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
  }

  /// Resolved locale (BCP-47 tag or system default).
  public var locale: Locale { localeTag.map { Locale(identifier: $0) } ?? .current }

  /// Builds the screen's view model from this configuration.
  @MainActor
  func makeViewModel() -> CalendarScreenViewModel {
    let today = CalendarMath.today(in: calendar)

    let maxSelectable: CalDate? = maxSelectableDate.map { CalDate($0, in: calendar) }
    let startMonth = today.calMonth
    let endMonth: CalMonth = maxSelectable
      .map { $0.calMonth.coercedAtLeast(startMonth) } ?? startMonth.adding(years: 1, in: calendar)

    // Clamp supplied dates into the selectable window [today, maxSelectable] so an out-of-range
    // initial value can't produce a selection outside the calendar.
    func clamp(_ date: CalDate) -> CalDate {
      var result = date
      if result < today { result = today }
      if let max = maxSelectable, result > max { result = max }
      return result
    }
    let going = goingDate.map { clamp(CalDate($0, in: calendar)) }
    let ret = returnDate.map { clamp(CalDate($0, in: calendar)) }
    let anchor: CalDate = (isReturn ? (ret ?? going) : going) ?? today
    let firstVisible = anchor.calMonth.coerced(in: startMonth, endMonth)

    // Per-day dot colors + names — later entries win for a shared date.
    var holidayDates: [CalDate: Color] = [:]
    var holidayNames: [CalDate: String] = [:]
    for entry in holidays {
      let color = Color(argb: entry.colorARGB)
      for d in entry.dates {
        holidayDates[d.calDate] = color
        holidayNames[d.calDate] = entry.description
      }
    }

    // Entries grouped by month, distinct by description within each month.
    var grouped: [CalMonth: [HolidayEntry]] = [:]
    for entry in holidays {
      for d in entry.dates {
        let month = CalMonth(year: d.year, month: d.month)
        grouped[month, default: []].append(entry)
      }
    }
    var byMonth: [BoundaryMonth: [HolidayEntry]] = [:]
    for (month, entries) in grouped {
      var seen = Set<String>()
      let distinct = entries.filter { seen.insert($0.description).inserted }
      byMonth[BoundaryMonth(month)] = distinct
    }

    let initialRange = SelectedRange(start: going, end: ret)

    let blocked = Set(blockedDates.map { CalDate($0, in: calendar) })
    var prices: [CalDate: String] = [:]
    for (date, text) in priceByDate { prices[CalDate(date, in: calendar)] = text }

    return CalendarScreenViewModel(
      today: Today(today),
      initialRange: initialRange,
      startMonth: BoundaryMonth(startMonth),
      endMonth: BoundaryMonth(endMonth),
      firstVisibleMonth: BoundaryMonth(firstVisible),
      holidayDates: HolidayDays(holidayDates),
      holidayNames: holidayNames,
      holidaysByMonth: HolidayByMonth(byMonth),
      locale: locale,
      isReturn: isReturn,
      maxSelectableDate: BoundaryDay(maxSelectable),
      blockedDates: blocked,
      priceByDate: prices,
      minNights: minNights,
      maxNights: maxNights,
      selectionMode: selectionMode,
      horizontalPaging: horizontalPaging,
      calendar: calendar,
      chrome: chrome,
      hapticsEnabled: hapticsEnabled,
      departurePlaceholder: departurePlaceholder,
      returnPlaceholder: returnPlaceholder,
      isDismissEndEnabled: isDismissEndEnabled,
      showPlusIconForReturn: showPlusIconForReturn)
  }
}
