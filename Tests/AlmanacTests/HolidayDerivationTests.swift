import XCTest
import SwiftUI
@testable import Almanac

/// Holiday map + legend derivation: per-date mapping and the visible-months legend computation.
@MainActor
final class HolidayDerivationTests: XCTestCase {

  func testLastEntryWinsForSharedDate() {
    let shared = ETSCalendarDate(day: 10, month: 7, year: 2026)
    let config = CalendarPickerConfiguration(holidays: [
      HolidayEntry(dates: [shared], colorARGB: 0xFF008CFF, description: "A"),
      HolidayEntry(dates: [shared], colorARGB: 0xFFFF0000, description: "B"),
    ])
    let vm = config.makeViewModel()
    // The later entry's color wins for the shared date.
    XCTAssertEqual(vm.holidayDates.dates[shared.calDate]?.argbValue, UInt32(0xFFFF0000))
  }

  func testLegendDistinctAndOrderedByDate() {
    let july = CalMonth(year: 2026, month: 7)
    let entries = [
      HolidayEntry(
        dates: [ETSCalendarDate(day: 20, month: 7, year: 2026)],
        colorARGB: 0xFFFF0000, description: "Later"),
      HolidayEntry(
        dates: [ETSCalendarDate(day: 5, month: 7, year: 2026)],
        colorARGB: 0xFF008CFF, description: "Earlier"),
      // Duplicate description should collapse.
      HolidayEntry(
        dates: [ETSCalendarDate(day: 25, month: 7, year: 2026)],
        colorARGB: 0xFF008CFF, description: "Earlier"),
    ]
    let vm = CalendarPickerConfiguration(holidays: entries).makeViewModel()
    vm.updateVisibleMonths(first: july, last: july)
    let descriptions = vm.visibleHolidayCategories.map(\.categoryDescription)
    XCTAssertEqual(descriptions, ["Earlier", "Later"])   // ordered by earliest date, deduped
  }

  func testLegendEmptyOutsideVisibleMonths() {
    let entries = [
      HolidayEntry(
        dates: [ETSCalendarDate(day: 5, month: 7, year: 2026)],
        colorARGB: 0xFF008CFF, description: "July"),
    ]
    let vm = CalendarPickerConfiguration(holidays: entries).makeViewModel()
    vm.updateVisibleMonths(first: CalMonth(year: 2026, month: 9), last: CalMonth(year: 2026, month: 10))
    XCTAssertTrue(vm.visibleHolidayCategories.isEmpty)
  }
}
