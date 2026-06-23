import XCTest
import SwiftUI
import SnapshotTesting
@testable import Almanac

/// Image snapshots of the static, deterministic components (day cell, top bar, footer).
/// The scrolling calendar grid and the wheel are excluded — their async layout isn't stable for
/// pixel comparison. References are machine/OS-specific; record locally with `record: .all`.
@MainActor
final class SnapshotTests: XCTestCase {

  override func setUpWithError() throws {
    // References are rendered on a specific simulator/OS; skip on CI to avoid false failures.
    try XCTSkipIf(
      ProcessInfo.processInfo.environment["CI"] != nil,
      "Snapshot references are machine/OS-specific; run locally.")
  }

  private let locale = Locale(identifier: "tr")

  // Slight tolerance for anti-aliasing/font-rendering differences across runs.
  private func assertImage(
    _ view: some View,
    width: CGFloat,
    height: CGFloat,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line)
  {
    let host = view
      .environment(\.colorScheme, .light)
      .frame(width: width, height: height)
      .background(Color.white)
    assertSnapshot(
      of: host,
      as: .image(precision: 0.98, perceptualPrecision: 0.96, layout: .fixed(width: width, height: height)),
      file: file, testName: testName, line: line)
  }

  func testDayCellStates() {
    let row = HStack(spacing: 2) {
      CalendarDayIndicator(day: 20, isSelected: false, isToday: true, isHoliday: false)
      CalendarDayIndicator(day: 21, isSelected: true, isToday: false, isHoliday: false)
      CalendarDayIndicator(day: 22, isSelected: false, isToday: false, isHoliday: true, isInBetween: true)
      CalendarDayIndicator(day: 23, isSelected: false, isToday: false, isHoliday: false, isDisabled: true)
      CalendarDayIndicator(day: 24, isSelected: true, isToday: false, isHoliday: false, isSameDay: true)
    }
    assertImage(row, width: 280, height: 60)
  }

  func testFooter() {
    let footer = CalendarFooter(
      holidayCategories: [
        HolidayCategory(color: .blue, categoryDescription: "Resmî Tatil", sortKey: 1),
        HolidayCategory(color: .red, categoryDescription: "Dinî Bayram", sortKey: 2),
      ],
      locale: locale,
      onClear: {},
      onApply: {})
    assertImage(footer, width: 360, height: 150)
  }

  func testTopBar() {
    let bar = CalendarTopBar(
      departureDate: SelectedDay(CalDate(year: 2026, month: 6, day: 25)),
      returnDate: SelectedDay(CalDate(year: 2026, month: 7, day: 1)),
      locale: locale,
      onBack: {},
      onClose: {})
    assertImage(bar, width: 360, height: 140)
  }
}
