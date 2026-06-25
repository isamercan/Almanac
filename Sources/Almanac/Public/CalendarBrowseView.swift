import SwiftUI

/// A self-contained **browse** surface that pairs a scrolling month grid with a year overview and
/// lets the user move between them (TimePage / ElegantCalendar-style):
///
/// - **Year mode** shows a `CalendarYearView` spanning the configured range. Tapping a month zooms
///   into the grid at that month.
/// - **Month mode** shows the scrolling grid (`CalendarGridView`) with live day selection. A toggle
///   in the header returns to the year overview.
///
/// Unlike `CalendarRangePickerView`, this is a *navigation/browse* component — it has no Apply/Clear
/// footer; selection is reported via `onSelectionChange` (fires on every change). Use it when you
/// want calendar-app-style browsing on top of Almanac's selection + holiday + style machinery.
///
///     CalendarBrowseView(configuration: CalendarPickerConfiguration(localeTag: "tr")) { result in
///       selectedRange = result   // result.goingDate / result.returnDate
///     }
public struct CalendarBrowseView: View {
  /// Which surface is showing.
  public enum Mode: Sendable { case year, month }

  private let configuration: CalendarPickerConfiguration
  private let onSelectionChange: ((CalendarPickerResult) -> Void)?

  @State private var mode: Mode
  // Owned internally: drives the year → month "zoom" jump. The grid wires its `scrollHandler`.
  @StateObject private var controller = CalendarController()
  @Environment(\.calendarStyle) private var style

  public init(
    initialMode: Mode = .year,
    configuration: CalendarPickerConfiguration,
    onSelectionChange: ((CalendarPickerResult) -> Void)? = nil)
  {
    self.configuration = configuration
    self.onSelectionChange = onSelectionChange
    _mode = State(initialValue: initialMode)
  }

  private var calendar: Calendar { configuration.calendar }
  private var locale: Locale { configuration.locale }
  private var isRTL: Bool { locale.language.characterDirection == .rightToLeft }

  /// First..last year covered, derived the same way the picker derives its month bounds:
  /// from today through `maxSelectableDate` (or +1 year when unset).
  private var yearSpan: ClosedRange<Int> {
    let today = CalendarMath.today(in: calendar)
    let startYear = today.year
    let endYear = configuration.maxSelectableDate.map { CalDate($0, in: calendar).year } ?? (today.year + 1)
    return startYear...max(startYear, endYear)
  }

  public var body: some View {
    VStack(spacing: 0) {
      header
      ZStack {
        // Always mounted so HorizonCalendar stays laid out and `controller` stays wired; the year
        // overlay simply covers it. Tapping a month scrolls this (hidden) grid, then the overlay
        // fades to reveal it already at the target month.
        CalendarGridView(
          configuration: configuration,
          controller: controller,
          onSelectionChange: onSelectionChange)

        if mode == .year {
          CalendarYearView(years: yearSpan, calendar: calendar, locale: locale) { month in
            controller.scroll(to: month.firstDayDate(in: calendar), animated: false)
            withAnimation(.easeInOut(duration: 0.25)) { mode = .month }
          }
          .background(style.theme.surface)
          .transition(.opacity)
        }
      }
    }
    .background(style.theme.surface)
    .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
  }

  private var header: some View {
    HStack {
      Button {
        withAnimation(.easeInOut(duration: 0.25)) { mode = (mode == .year ? .month : .year) }
      } label: {
        Label(
          mode == .year
            ? L10n.string(L10n.Key.months, locale: locale)
            : L10n.string(L10n.Key.yearOverview, locale: locale),
          systemImage: mode == .year ? "square.grid.2x2" : "calendar")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(style.theme.ink)
      }
      .buttonStyle(.plain)
      .accessibilityIdentifier("calendar.browse.toggle")
      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(style.theme.surface)
  }
}
