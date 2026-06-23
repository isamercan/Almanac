import XCTest
import SwiftUI
@testable import Almanac

/// Verifies the configurator's Swift-code generator emits only the fields that differ from
/// `.standard`, with correct syntax.
final class StyleCodeTests: XCTestCase {

  func testDefaultEmitsNoFieldLines() {
    let code = CalendarStyle.standard.generatedSwiftCode
    XCTAssertTrue(code.contains("var style = CalendarStyle.standard"))
    XCTAssertFalse(code.contains("style.theme"))
    XCTAssertFalse(code.contains("style.metrics"))
    XCTAssertFalse(code.contains("style.typography"))
  }

  func testEmitsOnlyChangedMetricAndTypography() {
    var style = CalendarStyle.standard
    style.metrics.footerCornerRadius = 12
    style.typography.dayNumber.size = 18
    style.typography.dayNumber.weight = .bold

    let code = style.generatedSwiftCode
    XCTAssertTrue(code.contains("style.metrics.footerCornerRadius = 12"))
    XCTAssertTrue(code.contains("style.typography.dayNumber.size = 18"))
    XCTAssertTrue(code.contains("style.typography.dayNumber.weight = .bold"))
    // Untouched fields must not appear.
    XCTAssertFalse(code.contains("buttonHeight"))
    XCTAssertFalse(code.contains("monthTitle"))
  }

  func testEmitsColorLiteralForChangedColor() {
    var style = CalendarStyle.standard
    style.theme.ink = Color(.sRGB, red: 1, green: 0, blue: 0, opacity: 1)
    let code = style.generatedSwiftCode
    XCTAssertTrue(code.contains("style.theme.ink = Color(.sRGB"))
  }
}
