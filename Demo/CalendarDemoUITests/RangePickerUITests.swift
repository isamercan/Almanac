import XCTest

/// End-to-end UI flow: open the range picker, apply / cancel, and verify the result surfaces back
/// in the menu. Relies on the accessibility identifiers exposed by Almanac + the demo.
final class RangePickerUITests: XCTestCase {

  override func setUp() {
    continueAfterFailure = false
  }

  func testOpenApplyShowsResult() {
    let app = XCUIApplication()
    app.launch()

    app.buttons["menu.range"].tap()

    let apply = app.buttons["calendar.apply"]
    XCTAssertTrue(apply.waitForExistence(timeout: 10), "calendar should appear")
    apply.tap()

    let result = app.staticTexts["menu.result"]
    XCTAssertTrue(result.waitForExistence(timeout: 5), "applying should surface a result")
    XCTAssertTrue(result.label.contains("Gidiş"), "result should contain the departure date")
  }

  func testOpenCloseCancels() {
    let app = XCUIApplication()
    app.launch()

    app.buttons["menu.range"].tap()

    let close = app.buttons["calendar.close"]
    XCTAssertTrue(close.waitForExistence(timeout: 10))
    close.tap()

    let result = app.staticTexts["menu.result"]
    XCTAssertTrue(result.waitForExistence(timeout: 5))
    XCTAssertEqual(result.label, "İptal edildi")
  }
}
