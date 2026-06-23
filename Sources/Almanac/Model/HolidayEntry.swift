import Foundation

// Cross-host input model — `Codable`/`Sendable` value types supplied by the host.

/// A calendar date as plain integers, exactly as supplied by the host.
public struct ETSCalendarDate: Hashable, Codable, Sendable {
  public let day: Int
  public let month: Int
  public let year: Int

  public init(day: Int, month: Int, year: Int) {
    self.day = day
    self.month = month
    self.year = year
  }

  /// Bridge to the internal calendar type.
  public var calDate: CalDate { CalDate(year: year, month: month, day: day) }
}

/// A holiday category and the days it covers.
/// `colorARGB` is a packed 0xAARRGGBB integer (alpha, red, green, blue).
public struct HolidayEntry: Hashable, Codable, Sendable, Identifiable {
  public let dates: [ETSCalendarDate]
  public let colorARGB: UInt32
  public let description: String

  public init(dates: [ETSCalendarDate], colorARGB: UInt32, description: String) {
    self.dates = dates
    self.colorARGB = colorARGB
    self.description = description
  }

  public var id: String { "\(description)#\(colorARGB)" }
}
