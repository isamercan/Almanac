import Foundation

/// What a tap before the start does while only the return can change (`isReturn`).
public enum CalendarReturnTapBeforeStart: Sendable {
  /// It is ignored (the default).
  case ignored
  /// It makes a same-day trip: the return becomes the start day — a travel booking's rule.
  case sameDay
}

/// What "Clear" clears.
public enum CalendarClearBehavior: Sendable {
  /// The whole range — except while only the return can change (`isReturn`), when it clears the
  /// return alone and is enabled only with one (the default).
  case contextual
  /// Always the whole range, enabled whenever a date is selected — a travel booking's rule.
  case all
}

/// Words that override the bundled (tr/en/ar) ones. `nil` keeps the bundled word.
public struct CalendarStrings: Equatable, Sendable {
  /// The top bar's title — "Tarih Seçin".
  public var title: String?
  /// The footer's "Temizle".
  public var clear: String?
  /// The footer's "Uygula".
  public var apply: String?

  public init(title: String? = nil, clear: String? = nil, apply: String? = nil) {
    self.title = title
    self.clear = clear
    self.apply = apply
  }
}
