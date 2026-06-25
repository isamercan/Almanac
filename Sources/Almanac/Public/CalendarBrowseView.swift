import SwiftUI

/// A self-contained **browse** surface that pairs a scrolling month grid with a year overview and
/// lets the user move between them (TimePage / ElegantCalendar-style):
///
/// - **Year mode** shows a `CalendarYearView` spanning the configured range. Months outside the
///   grid's navigable window are dimmed and disabled; tapping a live month zooms into the grid there.
/// - **Month mode** shows the scrolling grid (`CalendarGridView`) with live day selection. A toggle
///   in the header returns to the year overview. When a `.calendarSelectedDateAccessory` is provided
///   it renders below the grid for the selected day.
///
/// Unlike `CalendarRangePickerView`, this is a *navigation/browse* component — it has no Apply/Clear
/// footer; selection is reported via `onSelectionChange` (fires on every change). Pass a
/// `CalendarController` to drive the grid programmatically.
///
///     CalendarBrowseView(configuration: CalendarPickerConfiguration(localeTag: "tr")) { result in
///       selectedRange = result   // result.goingDate / result.returnDate
///     }
public struct CalendarBrowseView: View {
  /// Which surface is showing.
  public enum Mode: Sendable { case year, month }

  private let configuration: CalendarPickerConfiguration
  private let externalController: CalendarController?
  private let onSelectionChange: ((CalendarPickerResult) -> Void)?

  @State private var mode: Mode
  @State private var selectedDate: Date?
  // Drives the year → month "zoom" jump (the grid wires its `scrollHandler`). A host-supplied
  // controller takes precedence so the browse grid can also be driven externally.
  @StateObject private var internalController = CalendarController()
  @Environment(\.calendarStyle) private var style
  @Environment(\.calendarContent) private var content

  public init(
    initialMode: Mode = .year,
    configuration: CalendarPickerConfiguration,
    controller: CalendarController? = nil,
    onSelectionChange: ((CalendarPickerResult) -> Void)? = nil)
  {
    self.configuration = configuration
    self.externalController = controller
    self.onSelectionChange = onSelectionChange
    _mode = State(initialValue: initialMode)
  }

  private var controller: CalendarController { externalController ?? internalController }
  private var calendar: Calendar { configuration.calendar }
  private var locale: Locale { configuration.locale }
  private var isRTL: Bool { locale.language.characterDirection == .rightToLeft }

  /// The grid's navigable month window — the year overview aligns to this so it never offers a month
  /// the grid would silently clamp away.
  private var monthBounds: ClosedRange<CalMonth> { configuration.resolvedMonthBounds() }

  private var yearSpan: ClosedRange<Int> {
    let bounds = monthBounds
    return bounds.lowerBound.year...max(bounds.lowerBound.year, bounds.upperBound.year)
  }

  private var yearSpanLabel: String {
    let bounds = monthBounds
    let start = CalendarFormatting.yearTitle(bounds.lowerBound.year, locale: locale, calendar: calendar)
    guard bounds.lowerBound.year != bounds.upperBound.year else { return start }
    let end = CalendarFormatting.yearTitle(bounds.upperBound.year, locale: locale, calendar: calendar)
    return "\(start)–\(end)"
  }

  public var body: some View {
    VStack(spacing: 0) {
      header
      ZStack {
        // Always mounted so HorizonCalendar stays laid out and `controller` stays wired; the year
        // overlay simply covers it. Tapping a month scrolls this (hidden) grid, then the overlay
        // fades to reveal it already at the target month.
        CalendarGridView(configuration: configuration, controller: controller) { result in
          selectedDate = result.returnDate ?? result.goingDate
          onSelectionChange?(result)
        }

        if mode == .year {
          CalendarYearView(years: yearSpan, calendar: calendar, locale: locale, selectableMonths: monthBounds) { month in
            controller.scroll(to: month.firstDayDate(in: calendar), animated: false)
            withAnimation(.easeInOut(duration: 0.25)) { mode = .month }
          }
          .background(style.theme.surface)
          .transition(.opacity)
        }
      }

      if mode == .month, let accessory = content.selectedDateAccessory, let date = selectedDate {
        accessory(date)
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
          .calendarTextStyle(style.typography.button)
          .foregroundStyle(style.theme.ink)
      }
      .buttonStyle(.plain)
      .accessibilityIdentifier("calendar.browse.toggle")

      Spacer()

      if mode == .year {
        Text(yearSpanLabel)
          .calendarTextStyle(style.typography.monthTitle)
          .foregroundStyle(style.theme.ink)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(style.theme.surface)
  }
}
