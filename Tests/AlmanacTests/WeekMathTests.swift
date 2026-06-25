import XCTest
@testable import Almanac

/// `WeekMath` — week-boundary paging math used by `CalendarWeekView`, honouring the injected
/// calendar + firstWeekday.
final class WeekMathTests: XCTestCase {

  private func gregorian(firstWeekday: Int) -> Calendar {
    var cal = Calendar(identifier: .gregorian); cal.firstWeekday = firstWeekday; return cal
  }

  // Jan 1 2026 is a Thursday.

  func testWeekStartMondayFirst() {
    let start = WeekMath.weekStart(of: CalDate(year: 2026, month: 1, day: 1), calendar: gregorian(firstWeekday: 2))
    XCTAssertEqual(start, CalDate(year: 2025, month: 12, day: 29))   // Monday
  }

  func testWeekStartSundayFirst() {
    let start = WeekMath.weekStart(of: CalDate(year: 2026, month: 1, day: 1), calendar: gregorian(firstWeekday: 1))
    XCTAssertEqual(start, CalDate(year: 2025, month: 12, day: 28))   // Sunday
  }

  func testWeekStartSaturdayFirst() {
    let start = WeekMath.weekStart(of: CalDate(year: 2026, month: 1, day: 1), calendar: gregorian(firstWeekday: 7))
    XCTAssertEqual(start, CalDate(year: 2025, month: 12, day: 27))   // Saturday
  }

  /// The week start must always land on the calendar's first weekday — for any identifier.
  func testWeekStartLandsOnFirstWeekday() {
    for cal in [gregorian(firstWeekday: 2), gregorian(firstWeekday: 1), Calendar(identifier: .islamicUmmAlQura)] {
      let start = WeekMath.weekStart(of: CalDate(year: 2026, month: 6, day: 23), calendar: cal)
      let weekday = cal.component(.weekday, from: start.startOfDay(in: cal))
      XCTAssertEqual(weekday, cal.firstWeekday, "calendar \(cal.identifier)")
    }
  }

  func testWeekStartsCoverRangeSevenDaysApart() {
    let cal = gregorian(firstWeekday: 2)
    let starts = WeekMath.weekStarts(
      from: CalDate(year: 2026, month: 1, day: 1),
      to: CalDate(year: 2026, month: 1, day: 14),
      calendar: cal)
    XCTAssertEqual(starts, [
      CalDate(year: 2025, month: 12, day: 29),
      CalDate(year: 2026, month: 1, day: 5),
      CalDate(year: 2026, month: 1, day: 12),
    ])
  }

  func testIndexOfWeekContaining() {
    let cal = gregorian(firstWeekday: 2)
    let starts = WeekMath.weekStarts(
      from: CalDate(year: 2026, month: 1, day: 1),
      to: CalDate(year: 2026, month: 1, day: 14),
      calendar: cal)
    // Jan 8 sits in the second week (Jan 5–11).
    XCTAssertEqual(WeekMath.index(ofWeekContaining: CalDate(year: 2026, month: 1, day: 8), in: starts, calendar: cal), 1)
    // Way out of range ⇒ nil.
    XCTAssertNil(WeekMath.index(ofWeekContaining: CalDate(year: 2030, month: 1, day: 1), in: starts, calendar: cal))
  }

  func testEmptyWhenLowerAfterUpper() {
    let cal = gregorian(firstWeekday: 2)
    XCTAssertTrue(WeekMath.weekStarts(
      from: CalDate(year: 2026, month: 2, day: 1),
      to: CalDate(year: 2026, month: 1, day: 1),
      calendar: cal).isEmpty)
  }
}
