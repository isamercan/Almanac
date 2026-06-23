import Foundation

// Stable, value-semantic domain types. `CalDate`/`CalMonth` are timezone-stable calendar
// components; all arithmetic goes through `CalendarMath`.

/// A calendar day, identified purely by (year, month, day) — no time, no timezone.
public struct CalDate: Hashable, Comparable, Codable, Sendable {
  public let year: Int
  public let month: Int   // 1...12
  public let day: Int     // 1...31

  public init(year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day
  }

  /// Sortable key `yyyymmdd`. Valid only for well-formed dates; used for ordering, never math.
  public var sortKey: Int { year * 10000 + month * 100 + day }

  public static func < (lhs: CalDate, rhs: CalDate) -> Bool { lhs.sortKey < rhs.sortKey }

  /// `true` when this date is strictly before [other].
  public func isBefore(_ other: CalDate) -> Bool { self < other }
  /// `true` when this date is strictly after [other].
  public func isAfter(_ other: CalDate) -> Bool { self > other }

  public var calMonth: CalMonth { CalMonth(year: year, month: month) }
}

/// A year+month, no day.
public struct CalMonth: Hashable, Comparable, Codable, Sendable {
  public let year: Int
  public let month: Int   // 1...12

  public init(year: Int, month: Int) {
    self.year = year
    self.month = month
  }

  public var sortKey: Int { year * 100 + month }
  public static func < (lhs: CalMonth, rhs: CalMonth) -> Bool { lhs.sortKey < rhs.sortKey }

  public func isAfter(_ other: CalMonth) -> Bool { self > other }
  public func isBefore(_ other: CalMonth) -> Bool { self < other }
}

// MARK: - Thin stable wrappers (stable value types)

/// Wraps the (possibly nil) date shown in the top bar.
struct SelectedDay: Hashable, Sendable {
  public let date: CalDate?
  public init(_ date: CalDate?) { self.date = date }
}

/// Wraps an inclusive selectable boundary (min/max).
struct BoundaryDay: Hashable, Sendable {
  public let date: CalDate?
  public init(_ date: CalDate?) { self.date = date }
}

/// Wraps a month boundary.
struct BoundaryMonth: Hashable, Sendable {
  public let yearMonth: CalMonth
  public init(_ yearMonth: CalMonth) { self.yearMonth = yearMonth }
}

/// Wraps "today".
struct Today: Hashable, Sendable {
  public let date: CalDate
  public init(_ date: CalDate) { self.date = date }
}
