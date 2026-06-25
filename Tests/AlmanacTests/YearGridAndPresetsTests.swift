import XCTest
import SwiftUI
@testable import Almanac

/// Covers the new browse-surface date math (`YearGridMath` honouring the injected calendar +
/// firstWeekday), the year-title formatter, theme presets, and the additive chrome / wheel knobs.
@MainActor
final class YearGridAndPresetsTests: XCTestCase {

  // MARK: YearGridMath — leading blanks honour the calendar's firstWeekday

  func testLeadingBlanksMondayFirstGregorian() {
    // Jan 1 2026 is a Thursday. Monday-first ⇒ Mon,Tue,Wed are blank ⇒ 3.
    let jan2026 = CalMonth(year: 2026, month: 1)
    XCTAssertEqual(YearGridMath.leadingBlanks(for: jan2026, calendar: CalendarMath.gregorian), 3)
  }

  func testLeadingBlanksSundayFirstGregorian() {
    var cal = Calendar(identifier: .gregorian); cal.firstWeekday = 1   // Sunday
    XCTAssertEqual(YearGridMath.leadingBlanks(for: CalMonth(year: 2026, month: 1), calendar: cal), 4)
  }

  func testLeadingBlanksSaturdayFirstGregorian() {
    var cal = Calendar(identifier: .gregorian); cal.firstWeekday = 7   // Saturday
    XCTAssertEqual(YearGridMath.leadingBlanks(for: CalMonth(year: 2026, month: 1), calendar: cal), 5)
  }

  // MARK: YearGridMath — day counts come from the injected calendar, not hardcoded Gregorian

  func testGregorianDayCounts() {
    XCTAssertEqual(YearGridMath.dayCount(for: CalMonth(year: 2026, month: 1), calendar: CalendarMath.gregorian), 31)
    XCTAssertEqual(YearGridMath.dayCount(for: CalMonth(year: 2026, month: 2), calendar: CalendarMath.gregorian), 28)
    XCTAssertEqual(YearGridMath.dayCount(for: CalMonth(year: 2024, month: 2), calendar: CalendarMath.gregorian), 29) // leap
  }

  func testHijriDayCountsAreNeverThirtyOne() {
    // The bug being fixed: the year view used to hardcode Gregorian math. Hijri months are only
    // ever 29 or 30 days — proving the injected calendar is actually used.
    let hijri = Calendar(identifier: .islamicUmmAlQura)
    for month in 1...12 {
      let count = YearGridMath.dayCount(for: CalMonth(year: 1447, month: month), calendar: hijri)
      XCTAssertTrue(count == 29 || count == 30, "Hijri month \(month) had \(count) days")
    }
  }

  // MARK: Year title

  func testYearTitleGregorian() {
    let title = CalendarFormatting.yearTitle(2026, locale: Locale(identifier: "en"), calendar: CalendarMath.gregorian)
    XCTAssertTrue(title.contains("2026"), "Expected the Gregorian year title to contain 2026, got \(title)")
  }

  // MARK: Theme presets

  func testThemePresetCount() {
    XCTAssertEqual(CalendarThemePreset.allCases.count, 5)
  }

  func testStandardPresetMatchesStandardTheme() {
    XCTAssertEqual(
      CalendarThemePreset.standard.theme.ink.argbValue,
      CalendarTheme.standard.ink.argbValue)
  }

  func testAlternatePresetsDifferFromStandard() {
    let standardInk = CalendarTheme.standard.ink.argbValue
    for preset in [CalendarThemePreset.ocean, .sunset, .forest, .midnight] {
      XCTAssertNotEqual(preset.theme.ink.argbValue, standardInk, "\(preset.displayName) ink should differ from standard")
    }
  }

  func testPresetDisplayNames() {
    XCTAssertEqual(CalendarThemePreset.ocean.displayName, "Ocean")
    XCTAssertEqual(CalendarThemePreset.midnight.displayName, "Midnight")
  }

  // MARK: Additive chrome / wheel defaults (must preserve stock behaviour)

  func testTodayButtonOffByDefault() {
    XCTAssertFalse(CalendarChrome().showsTodayButton)
    XCTAssertFalse(CalendarChrome.full.showsTodayButton)
    XCTAssertFalse(CalendarChrome.none.showsTodayButton)
  }

  func testWheelHapticsEnabledByDefault() {
    XCTAssertTrue(TimePickerConfig().hapticsEnabled)
  }
}
