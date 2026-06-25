import XCTest
@testable import Almanac

/// `CalendarPickerConfiguration.makeViewModel` month-bounds, clamping, chrome and timezone behaviour.
@MainActor
final class ConfigurationTests: XCTestCase {

  private let cal = CalendarMath.gregorian
  private func date(_ daysFromNow: Int) -> Date {
    cal.date(byAdding: .day, value: daysFromNow, to: cal.startOfDay(for: Date())) ?? Date()
  }

  func testEndMonthDefaultsToOneYearAhead() {
    let vm = CalendarPickerConfiguration().makeViewModel()
    XCTAssertEqual(vm.endMonth.yearMonth, vm.startMonth.yearMonth.adding(years: 1))
  }

  func testEndMonthFollowsMaxSelectableDate() {
    let vm = CalendarPickerConfiguration(maxSelectableDate: date(400)).makeViewModel()
    XCTAssertEqual(vm.endMonth.yearMonth, CalDate(date(400)).calMonth)
    XCTAssertTrue(vm.endMonth.yearMonth > vm.startMonth.yearMonth)
  }

  func testStartMonthIsThisMonth() {
    let vm = CalendarPickerConfiguration().makeViewModel()
    XCTAssertEqual(vm.startMonth.yearMonth, CalendarMath.today().calMonth)
  }

  func testGoingDateClampedIntoRange() {
    // Going far beyond the max → clamped to the max selectable day.
    let vm = CalendarPickerConfiguration(goingDate: date(400), maxSelectableDate: date(10)).makeViewModel()
    XCTAssertEqual(vm.selectedRange.start, CalDate(date(10)))
  }

  func testFirstVisibleMonthClampedIntoBounds() {
    let vm = CalendarPickerConfiguration(goingDate: date(400), maxSelectableDate: date(10)).makeViewModel()
    XCTAssertTrue(vm.firstVisibleMonth.yearMonth >= vm.startMonth.yearMonth)
    XCTAssertTrue(vm.firstVisibleMonth.yearMonth <= vm.endMonth.yearMonth)
  }

  func testResolvedMonthBoundsMatchViewModel() {
    // The browse / week views derive their navigable window from resolvedMonthBounds(); it must
    // agree exactly with the grid's view-model bounds so they never disagree on which months exist.
    let config = CalendarPickerConfiguration(maxSelectableDate: date(400))
    let bounds = config.resolvedMonthBounds()
    let vm = config.makeViewModel()
    XCTAssertEqual(bounds.lowerBound, vm.startMonth.yearMonth)
    XCTAssertEqual(bounds.upperBound, vm.endMonth.yearMonth)
  }

  func testResolvedMonthBoundsDefaultsToOneYear() {
    let bounds = CalendarPickerConfiguration().resolvedMonthBounds()
    XCTAssertEqual(bounds.lowerBound, CalendarMath.today().calMonth)
    XCTAssertEqual(bounds.upperBound, bounds.lowerBound.adding(years: 1))
  }

  func testChromePresets() {
    XCTAssertTrue(CalendarChrome.full.showsTopBar)
    XCTAssertTrue(CalendarChrome.full.showsFooter)
    let none = CalendarChrome.none
    XCTAssertFalse(none.showsTitleBar)
    XCTAssertFalse(none.showsDateRow)
    XCTAssertFalse(none.showsTopBar)
    XCTAssertFalse(none.showsFooter)
    XCTAssertTrue(none.showsWeekdayHeader)
  }

  func testCalDateRespectsInjectedTimeZone() {
    var utc = Calendar(identifier: .gregorian); utc.timeZone = TimeZone(identifier: "UTC")!
    var istanbul = Calendar(identifier: .gregorian); istanbul.timeZone = TimeZone(identifier: "Europe/Istanbul")!
    // 2026-01-01 23:30 UTC — still Jan 1 in UTC, already Jan 2 in Istanbul (+3).
    let instant = utc.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 23, minute: 30))!
    XCTAssertEqual(CalDate(instant, in: utc), CalDate(year: 2026, month: 1, day: 1))
    XCTAssertEqual(CalDate(instant, in: istanbul), CalDate(year: 2026, month: 1, day: 2))
  }

  func testEpochDayRoundTripInFixedTimeZone() {
    var istanbul = Calendar(identifier: .gregorian); istanbul.timeZone = TimeZone(identifier: "Europe/Istanbul")!
    let d = CalDate(year: 2026, month: 6, day: 23)
    XCTAssertEqual(CalDate(epochDay: d.epochDay(in: istanbul), in: istanbul), d)
  }
}
