import SwiftUI

/// Everything a custom day cell needs to render itself — the public, render-ready model handed to
/// a `.calendarDay { … }` content closure. Inspired by OBCalendar's layered day model, adapted to
/// this kit's range/holiday/price domain.
public struct CalendarDayContext: Equatable {
  public let date: Date            // start-of-day
  public let day: Int
  public let month: Int
  public let year: Int

  public let isToday: Bool
  public let isSelected: Bool      // either endpoint
  public let isRangeStart: Bool
  public let isRangeEnd: Bool
  public let isInBetween: Bool
  public let isSameDay: Bool       // single-day range (start == end)
  public let isDisabled: Bool
  public let isBlocked: Bool
  public let isCurrentMonth: Bool

  public let holidayColor: Color?
  public let holidayName: String?
  public let badge: String?
}

/// Holds optional view overrides for the calendar's building blocks. Stored in the environment via
/// the `.calendar*` modifiers; components fall back to their default rendering when an override is
/// absent. Type-erased to keep the public views non-generic.
struct CalendarContent {
  var day: ((CalendarDayContext) -> AnyView)?
  var weekdayHeader: ((Int, Locale) -> AnyView)?       // weekdayIndex (0 = Sunday … 6 = Saturday)
  var monthHeader: ((CalMonth, Locale) -> AnyView)?
  var legend: (([HolidayCategory]) -> AnyView)?
  /// Accessory shown above the footer when a date is selected (the range end, else the start).
  var selectedDateAccessory: ((Date) -> AnyView)?
}

private struct CalendarContentKey: EnvironmentKey {
  static let defaultValue = CalendarContent()
}

extension EnvironmentValues {
  var calendarContent: CalendarContent {
    get { self[CalendarContentKey.self] }
    set { self[CalendarContentKey.self] = newValue }
  }
}

public extension View {
  /// Provides a custom view for each day cell. Receives a fully-resolved ``CalendarDayContext``.
  /// The default `CalendarDayIndicator` is used when this is not set.
  func calendarDay(@ViewBuilder _ content: @escaping (CalendarDayContext) -> some View) -> some View {
    transformEnvironment(\.calendarContent) { value in
      value.day = { ctx in AnyView(content(ctx)) }
    }
  }

  /// Provides a custom day-of-week header cell. `weekdayIndex`: 0 = Sunday … 6 = Saturday.
  func calendarWeekdayHeader(@ViewBuilder _ content: @escaping (Int, Locale) -> some View) -> some View {
    transformEnvironment(\.calendarContent) { value in
      value.weekdayHeader = { index, locale in AnyView(content(index, locale)) }
    }
  }

  /// Provides a custom month-title header.
  func calendarMonthHeader(@ViewBuilder _ content: @escaping (CalMonth, Locale) -> some View) -> some View {
    transformEnvironment(\.calendarContent) { value in
      value.monthHeader = { month, locale in AnyView(content(month, locale)) }
    }
  }

  /// Provides a custom footer legend for the currently-visible holiday categories.
  func calendarLegend(@ViewBuilder _ content: @escaping ([HolidayCategory]) -> some View) -> some View {
    transformEnvironment(\.calendarContent) { value in
      value.legend = { categories in AnyView(content(categories)) }
    }
  }

  /// Provides an accessory view rendered above the footer whenever a date is selected — fed the most
  /// relevant day (the range end if set, otherwise the start), as a start-of-day `Date`. Use it for
  /// calendar-app-style detail (events, notes, a fare summary…). Hidden when nothing is selected.
  func calendarSelectedDateAccessory(@ViewBuilder _ content: @escaping (Date) -> some View) -> some View {
    transformEnvironment(\.calendarContent) { value in
      value.selectedDateAccessory = { date in AnyView(content(date)) }
    }
  }
}
