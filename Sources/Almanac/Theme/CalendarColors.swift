import SwiftUI

// Calendar color tokens. Light values are the brand palette; dark values are added for
// dark-mode support.
// These back the default `CalendarTheme.standard`; hosts can override via `.calendarTheme(_:)`.
public enum CalendarColors {
  public static let ink = Color(lightARGB: 0xFF00121C, darkARGB: 0xFFF2F4F5)            // primary text + selected fill
  public static let onInk = Color(lightARGB: 0xFFFFFFFF, darkARGB: 0xFF00121C)          // content on the ink fill
  public static let surface = Color(lightARGB: 0xFFFFFFFF, darkARGB: 0xFF111417)        // page + day-cell background
  public static let line = Color(lightARGB: 0xFFD3D5D6, darkARGB: 0xFF3A3C3E)           // borders, dividers, disabled
  public static let weekendText = Color(lightARGB: 0xFF696A6B, darkARGB: 0xFF9A9C9D)    // weekend labels
  public static let todayRing = Color(lightARGB: 0xFFBEC1C2, darkARGB: 0xFF5A5C5E)      // outline around today
  public static let inBetweenFill = Color(lightARGB: 0xFFEBECEC, darkARGB: 0xFF2C2E30)  // in-range day fill
  public static let holidayDot = Color(argb: 0xFF008CFF)                                // default holiday indicator
  public static let disabledButtonContainer = Color(lightARGB: 0xFFEBECEC, darkARGB: 0xFF2C2E30)
  public static let disabledButtonContent = Color(lightARGB: 0xFFBEC1C2, darkARGB: 0xFF5A5C5E)
}
