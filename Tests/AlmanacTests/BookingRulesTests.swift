import XCTest
@testable import Almanac

/// The opt-in booking rules (0.3.0): a later first selectable day, a same-day return from a tap
/// before the start, "Clear" clearing everything, an inverted initial range dropped, the empty
/// legend gone, the date-row pattern and the overridable words.
@MainActor
final class BookingRulesTests: XCTestCase {

  private let today = CalDate(year: 2026, month: 6, day: 22)
  private let cal = CalendarMath.gregorian

  private func date(_ daysFromNow: Int) -> Date {
    cal.date(byAdding: .day, value: daysFromNow, to: cal.startOfDay(for: Date())) ?? Date()
  }

  private func makeVM(
    isReturn: Bool = false,
    initial: SelectedRange = SelectedRange(),
    minimum: CalDate? = nil,
    returnTap: CalendarReturnTapBeforeStart = .ignored,
    clear: CalendarClearBehavior = .contextual) -> CalendarScreenViewModel
  {
    CalendarScreenViewModel(
      today: Today(today),
      initialRange: initial,
      startMonth: BoundaryMonth(today.calMonth),
      endMonth: BoundaryMonth(today.calMonth.adding(years: 1)),
      firstVisibleMonth: BoundaryMonth(today.calMonth),
      holidayDates: HolidayDays(),
      holidaysByMonth: HolidayByMonth(),
      locale: Locale(identifier: "tr"),
      isReturn: isReturn,
      maxSelectableDate: BoundaryDay(nil),
      minimumDay: minimum,
      returnTapBeforeStart: returnTap,
      clearBehavior: clear)
  }

  // MARK: - minimumDate

  func testDaysBeforeTheMinimumCantBeTappedAndAreDisabled() {
    let vm = makeVM(minimum: today.adding(days: 5))
    XCTAssertFalse(vm.isSelectable(today.adding(days: 4)))
    XCTAssertTrue(vm.isSelectable(today.adding(days: 5)))
    XCTAssertTrue(vm.dayState(for: today.adding(days: 4)).isDisabled)
    vm.onDayTapped(today.adding(days: 4))
    XCTAssertNil(vm.selectedRange.start)
  }

  func testAMinimumBeforeTodayIsToday() {
    let vm = makeVM(minimum: today.adding(days: -10))
    XCTAssertFalse(vm.isSelectable(today.adding(days: -1)))
    XCTAssertTrue(vm.isSelectable(today))
  }

  func testTheMonthsStartAtTheMinimumsMonth() {
    let config = CalendarPickerConfiguration(minimumDate: date(70))
    let vm = config.makeViewModel()
    XCTAssertEqual(vm.startMonth.yearMonth, CalDate(date(70)).calMonth)
    XCTAssertEqual(config.resolvedMonthBounds().lowerBound, vm.startMonth.yearMonth)
    XCTAssertEqual(vm.endMonth.yearMonth, CalendarMath.today().calMonth.adding(years: 1),
                   "the window still ends a year after today")
  }

  func testInitialDatesAreClampedToTheMinimum() {
    let vm = CalendarPickerConfiguration(goingDate: date(1), minimumDate: date(5)).makeViewModel()
    XCTAssertEqual(vm.selectedRange.start, CalDate(date(5)))
  }

  // MARK: - Return tap before the start

  func testATapBeforeTheStartIsIgnoredByDefault() {
    let vm = makeVM(isReturn: true, initial: SelectedRange(start: today.adding(days: 5)))
    vm.onDayTapped(today.adding(days: 2))
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 5)))
  }

  func testATapBeforeTheStartMakesASameDayTripWhenAsked() {
    let vm = makeVM(isReturn: true, initial: SelectedRange(start: today.adding(days: 5)), returnTap: .sameDay)
    vm.onDayTapped(today.adding(days: 2))
    XCTAssertEqual(vm.selectedRange, SelectedRange(start: today.adding(days: 5), end: today.adding(days: 5)))
    vm.onDayTapped(today.adding(days: 9))
    XCTAssertEqual(vm.selectedRange.end, today.adding(days: 9), "a later tap still moves the return")
  }

  // MARK: - Clear

  func testClearIsContextualByDefault() {
    let vm = makeVM(isReturn: true, initial: SelectedRange(start: today.adding(days: 5)))
    XCTAssertFalse(vm.clearEnabled, "nothing to clear on the return side")
  }

  func testClearAllClearsBothWheneverADateIsSelected() {
    let vm = makeVM(isReturn: true, initial: SelectedRange(start: today.adding(days: 5)), clear: .all)
    XCTAssertTrue(vm.clearEnabled)
    vm.clear()
    XCTAssertEqual(vm.selectedRange, SelectedRange())
    XCTAssertFalse(vm.clearEnabled)
  }

  // MARK: - Initial range

  func testAnInitialReturnBeforeTheDepartureIsDropped() {
    let vm = CalendarPickerConfiguration(goingDate: date(10), returnDate: date(4)).makeViewModel()
    XCTAssertEqual(vm.selectedRange.start, CalDate(date(10)))
    XCTAssertNil(vm.selectedRange.end)
  }

  func testAnInitialSameDayRangeIsKept() {
    let vm = CalendarPickerConfiguration(goingDate: date(10), returnDate: date(10)).makeViewModel()
    XCTAssertEqual(vm.selectedRange.end, CalDate(date(10)))
  }

  // MARK: - Words and date row

  func testTheDateRowFollowsTheGivenPattern() {
    let day = CalDate(year: 2026, month: 10, day: 9)
    XCTAssertEqual(CalendarFormatting.longDate(day, locale: Locale(identifier: "tr"), format: "d MMMM yyyy"), "9 Ekim 2026")
    XCTAssertEqual(CalendarFormatting.longDate(day, locale: Locale(identifier: "en"), format: "d MMMM yyyy"), "9 October 2026")
  }

  func testTheWordsReachTheViewModel() {
    let vm = CalendarPickerConfiguration(
      dateFormat: "d MMMM yyyy",
      strings: CalendarStrings(title: "Tarih Seçin", clear: "Temizle", apply: "Uygula")).makeViewModel()
    XCTAssertEqual(vm.dateFormat, "d MMMM yyyy")
    XCTAssertEqual(vm.strings.title, "Tarih Seçin")
    XCTAssertEqual(vm.strings.apply, "Uygula")
  }

  func testTheDefaultsKeepTheStandardBehaviour() {
    let config = CalendarPickerConfiguration()
    XCTAssertNil(config.minimumDate)
    XCTAssertEqual(config.returnTapBeforeStart, .ignored)
    XCTAssertEqual(config.clearBehavior, .contextual)
    XCTAssertEqual(CalendarMetrics().sameDayStyle, .innerRing)
  }
}
