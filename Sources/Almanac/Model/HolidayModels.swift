import SwiftUI

// Resolved, render-ready holiday models. Swift dictionaries/arrays are already value types, so no
// immutable-collections dependency is needed.

/// Per-day dot colors.
struct HolidayDays: Equatable, Sendable {
  public let dates: [CalDate: Color]
  public init(_ dates: [CalDate: Color] = [:]) { self.dates = dates }
}

/// Entries grouped by month, used only to drive the footer legend.
struct HolidayByMonth: Equatable, Sendable {
  public let holidaysByMonth: [BoundaryMonth: [HolidayEntry]]
  public init(_ holidaysByMonth: [BoundaryMonth: [HolidayEntry]] = [:]) {
    self.holidaysByMonth = holidaysByMonth
  }
}

/// One row of the footer legend.
public struct HolidayCategory: Equatable, Identifiable, Sendable {
  public let color: Color
  public let categoryDescription: String
  /// Stable date key (yyyymmdd) used to keep the legend ordered by date.
  public let sortKey: Int

  public init(color: Color, categoryDescription: String, sortKey: Int = 0) {
    self.color = color
    self.categoryDescription = categoryDescription
    self.sortKey = sortKey
  }

  /// Stable identity within the legend: description plus color. Disambiguates same-named
  /// categories that differ in color, and stays stable across scroll (unlike `sortKey`).
  public var legendKey: String { "\(categoryDescription)#\(color.argbValue)" }
  public var id: String { legendKey }
}
