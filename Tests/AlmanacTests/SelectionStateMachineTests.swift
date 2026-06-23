import XCTest
@testable import Almanac

/// Locks down the day-tap state machine — the behavioural contract ported from
/// `CalendarRangeSelector.onDayClicked` / `RangeDayCell`.
@MainActor
final class SelectionStateMachineTests: XCTestCase {

  private let today = CalDate(year: 2026, month: 6, day: 22)

  private func makeVM(
    isReturn: Bool = false,
    initial: SelectedRange = SelectedRange(),
    max: CalDate? = nil,
    blocked: Set<CalDate> = [],
    minNights: Int? = nil,
    maxNights: Int? = nil,
    mode: CalendarSelectionMode = .range) -> CalendarScreenViewModel
  {
    CalendarScreenViewModel(
      today: Today(today),
      initialRange: initial,
      startMonth: BoundaryMonth(today.calMonth),
      endMonth: BoundaryMonth(today.calMonth.adding(years: 1)),
      firstVisibleMonth: BoundaryMonth(today.calMonth),
      holidayDates: HolidayDays(),
      holidaysByMonth: HolidayByMonth(),
      locale: Locale(identifier: "en"),
      isReturn: isReturn,
      maxSelectableDate: BoundaryDay(max),
      blockedDates: blocked,
      minNights: minNights,
      maxNights: maxNights,
      selectionMode: mode)
  }

  func testFirstTapResetsToNewDepartureAndClearsReturn() {
    let vm = makeVM(initial: SelectedRange(start: today.adding(days: 3), end: today.adding(days: 9)))
    vm.onDayTapped(today.adding(days: 5))
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 5), end: nil))
  }

  func testSecondTapClosesRange() {
    let vm = makeVM()
    vm.onDayTapped(today.adding(days: 2)) // first tap → start
    vm.onDayTapped(today.adding(days: 6)) // closes
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 2), end: today.adding(days: 6)))
  }

  func testTapBeforeStartRestarts() {
    let vm = makeVM()
    vm.onDayTapped(today.adding(days: 5)) // start
    vm.onDayTapped(today.adding(days: 2)) // earlier → restart
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 2), end: nil))
  }

  func testCompletedRangeThenTapStartsFresh() {
    let vm = makeVM()
    vm.onDayTapped(today.adding(days: 2))
    vm.onDayTapped(today.adding(days: 6)) // complete
    vm.onDayTapped(today.adding(days: 8)) // fresh start
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 8), end: nil))
  }

  func testLockStartOnlyMovesEnd() {
    let start = today.adding(days: 3)
    let vm = makeVM(isReturn: true, initial: SelectedRange(start: start, end: nil))
    vm.onDayTapped(today.adding(days: 5))
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: start, end: today.adding(days: 5)))
    // A later tap moves the end again; the start never changes.
    vm.onDayTapped(today.adding(days: 9))
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: start, end: today.adding(days: 9)))
  }

  func testLockStartIgnoresTapBeforeStart() {
    let start = today.adding(days: 5)
    let vm = makeVM(isReturn: true, initial: SelectedRange(start: start, end: nil))
    vm.onDayTapped(today.adding(days: 2)) // before locked start → ignored
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: start, end: nil))
  }

  func testCannotSelectBeforeToday() {
    let vm = makeVM()
    vm.onDayTapped(today.adding(days: -1))
    XCTAssertEqual(vm.selectedRange, SelectedRange())
  }

  func testCannotSelectAfterMax() {
    let vm = makeVM(max: today.adding(days: 5))
    vm.onDayTapped(today.adding(days: 10))
    XCTAssertEqual(vm.selectedRange, SelectedRange())
    vm.onDayTapped(today.adding(days: 5)) // exactly max is allowed
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 5), end: nil))
  }

  func testDayStateInBetweenAndEndpoints() {
    let vm = makeVM(initial: SelectedRange(start: today.adding(days: 2), end: today.adding(days: 6)))
    // firstTap is still pending here (departure screen); read state directly without tapping.
    XCTAssertTrue(vm.dayState(for: today.adding(days: 2)).isSelected)
    XCTAssertTrue(vm.dayState(for: today.adding(days: 6)).isSelected)
    XCTAssertTrue(vm.dayState(for: today.adding(days: 4)).isInBetween)
    XCTAssertFalse(vm.dayState(for: today.adding(days: 7)).isInBetween)
    XCTAssertTrue(vm.dayState(for: today.adding(days: -1)).isDisabled)
  }

  func testMinNightsRejectsTooShortEnd() {
    let vm = makeVM(minNights: 3)
    vm.onDayTapped(today.adding(days: 2))   // start
    vm.onDayTapped(today.adding(days: 3))   // only 1 night → rejected, range stays open
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 2), end: nil))
    vm.onDayTapped(today.adding(days: 5))   // 3 nights → accepted
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 2), end: today.adding(days: 5)))
  }

  func testMaxNightsRejectsTooLongEnd() {
    let vm = makeVM(maxNights: 5)
    vm.onDayTapped(today.adding(days: 1))
    vm.onDayTapped(today.adding(days: 10))  // 9 nights → rejected
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 1), end: nil))
  }

  func testBlockedDateNotSelectableAndNotSpanned() {
    let blockedDay = today.adding(days: 4)
    let vm = makeVM(blocked: [blockedDay])
    vm.onDayTapped(blockedDay)              // blocked → ignored
    XCTAssertEqual(vm.selectedRange, SelectedRange())
    vm.onDayTapped(today.adding(days: 2))   // start
    vm.onDayTapped(today.adding(days: 6))   // would span the blocked day → rejected
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 2), end: nil))
    XCTAssertTrue(vm.dayState(for: blockedDay).isDisabled)
  }

  func testSingleModeSelectsOneDay() {
    let vm = makeVM(mode: .single)
    vm.onDayTapped(today.adding(days: 3))
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 3), end: nil))
    vm.onDayTapped(today.adding(days: 7))   // moves to the new single day, never a range
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 7), end: nil))
    XCTAssertFalse(vm.showsReturn)
  }

  func testClearAndApplyEnablement() {
    let vm = makeVM()
    XCTAssertFalse(vm.applyEnabled)
    XCTAssertFalse(vm.clearEnabled)
    vm.onDayTapped(today.adding(days: 3))
    XCTAssertTrue(vm.applyEnabled)
    XCTAssertTrue(vm.clearEnabled)
    vm.clear()
    XCTAssertEqual(vm.selectedRange, SelectedRange())
  }
}
