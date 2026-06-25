import Foundation

// Localization for the self-contained Almanac bundle.
// Strings live in `Resources/{tr,en}.lproj` under the `etscalendar_*` key names.
// The host may override the language via a BCP-47 tag (resolved through `Locale(identifier:)`).

enum L10n {
  /// String keys.
  enum Key {
    static let clear = "etscalendar_clear"
    static let apply = "etscalendar_action_apply"
    static let selectDatePrompt = "etscalendar_select_date_prompt"
    static let back = "etscalendar_back"
    static let clearReturnDate = "etscalendar_clear_return_date"
    static let close = "etscalendar_close"
    static let departureDate = "etscalendar_departure_date"
    static let addReturn = "etscalendar_add_return"
    static let rentacarPickup = "etscalendar_rentacar_pickup_date_title"
    static let rentacarDropOff = "etscalendar_rentacar_drop_off_date_title"
    static let hotelCheckin = "etscalendar_hotel_checkin_date_title"
    static let hotelCheckout = "etscalendar_hotel_checkout_date_title"
    static let today = "etscalendar_today"
    static let yearOverview = "etscalendar_year_overview"
    static let months = "etscalendar_months"

    // VoiceOver state words for day cells.
    static let a11yToday = "etscalendar_a11y_today"
    static let a11ySelectedStart = "etscalendar_a11y_selected_start"
    static let a11ySelectedEnd = "etscalendar_a11y_selected_end"
    static let a11ySelectedSingle = "etscalendar_a11y_selected_single"
    static let a11yInRange = "etscalendar_a11y_in_range"
    static let a11yUnavailable = "etscalendar_a11y_unavailable"
    static let a11yHourColumn = "etscalendar_a11y_hour"
    static let a11yMinuteColumn = "etscalendar_a11y_minute"
    static let a11yAmPmColumn = "etscalendar_a11y_ampm"
  }

  /// Resolves [key] for [locale], picking the matching `.lproj` inside the Almanac bundle and
  /// falling back to the bundle default (tr). Independent of the host app's locale plumbing.
  static func string(_ key: String, locale: Locale) -> String {
    let lang = locale.language.languageCode?.identifier ?? "tr"
    if let path = Bundle.module.path(forResource: lang, ofType: "lproj"),
       let bundle = Bundle(path: path) {
      return bundle.localizedString(forKey: key, value: key, table: nil)
    }
    return Bundle.module.localizedString(forKey: key, value: key, table: nil)
  }
}
