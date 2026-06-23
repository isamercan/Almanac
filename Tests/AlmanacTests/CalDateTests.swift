import XCTest
@testable import Almanac

/// Date arithmetic correctness.
final class CalDateTests: XCTestCase {

  func testComparisonAndPredicates() {
    let a = CalDate(year: 2026, month: 6, day: 22)
    let b = CalDate(year: 2026, month: 6, day: 23)
    XCTAssertTrue(a.isBefore(b))
    XCTAssertTrue(b.isAfter(a))
    XCTAssertFalse(a.isBefore(a))
  }

  func testAddingDaysAcrossMonthBoundary() {
    let end = CalDate(year: 2026, month: 1, day: 31).adding(days: 1)
    XCTAssertEqual(end, CalDate(year: 2026, month: 2, day: 1))
  }

  func testEpochDayRoundTrip() {
    let d = CalDate(year: 2026, month: 6, day: 22)
    XCTAssertEqual(CalDate(epochDay: d.epochDay), d)
    XCTAssertEqual(CalDate(year: 1970, month: 1, day: 1).epochDay, 0)
  }

  func testMonthArithmetic() {
    let m = CalMonth(year: 2026, month: 11)
    XCTAssertEqual(m.adding(months: 2), CalMonth(year: 2027, month: 1))
    XCTAssertEqual(m.adding(years: 1), CalMonth(year: 2027, month: 11))
  }

  func testMonthCoercion() {
    let lower = CalMonth(year: 2026, month: 6)
    let upper = CalMonth(year: 2027, month: 6)
    XCTAssertEqual(CalMonth(year: 2025, month: 1).coerced(in: lower, upper), lower)
    XCTAssertEqual(CalMonth(year: 2030, month: 1).coerced(in: lower, upper), upper)
    XCTAssertEqual(CalMonth(year: 2026, month: 9).coerced(in: lower, upper), CalMonth(year: 2026, month: 9))
    XCTAssertEqual(CalMonth(year: 2025, month: 1).coercedAtLeast(lower), lower)
  }

  func testLeapMonthLastDay() {
    let feb = CalMonth(year: 2028, month: 2)   // 2028 is a leap year
    XCTAssertEqual(CalDate(feb.lastDayDate), CalDate(year: 2028, month: 2, day: 29))
  }

  func testSelectedRangeSceneEncodingRoundTrip() {
    let full = SelectedRange(
      start: CalDate(year: 2026, month: 6, day: 25),
      end: CalDate(year: 2026, month: 7, day: 1))
    XCTAssertEqual(SelectedRange(sceneEncoded: full.sceneEncoded), full)

    let partial = SelectedRange(start: CalDate(year: 2026, month: 6, day: 25), end: nil)
    XCTAssertEqual(SelectedRange(sceneEncoded: partial.sceneEncoded), partial)

    let empty = SelectedRange()
    XCTAssertEqual(SelectedRange(sceneEncoded: empty.sceneEncoded), empty)

    XCTAssertNil(SelectedRange(sceneEncoded: "garbage-without-separator"))
  }
}
