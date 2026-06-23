import XCTest
@testable import Almanac

/// 12 ↔ 24 hour conversion parity with `to24Hour` / `from24Hour`.
final class HourConversionTests: XCTestCase {

  func testTo24Hour() {
    XCTAssertEqual(to24Hour(12, isAm: true), 0)
    XCTAssertEqual(to24Hour(12, isAm: false), 12)
    XCTAssertEqual(to24Hour(1, isAm: true), 1)
    XCTAssertEqual(to24Hour(1, isAm: false), 13)
    XCTAssertEqual(to24Hour(11, isAm: false), 23)
  }

  func testFrom24Hour() {
    XCTAssertEqual(from24Hour(0).hour12, 12)
    XCTAssertTrue(from24Hour(0).isAm)
    XCTAssertEqual(from24Hour(12).hour12, 12)
    XCTAssertFalse(from24Hour(12).isAm)
    XCTAssertEqual(from24Hour(13).hour12, 1)
    XCTAssertFalse(from24Hour(13).isAm)
    XCTAssertEqual(from24Hour(23).hour12, 11)
  }

  func testRoundTrip() {
    for h in 0...23 {
      let (h12, am) = from24Hour(h)
      XCTAssertEqual(to24Hour(h12, isAm: am), h)
    }
  }
}
