import Foundation

/// The picked date range, with `contains`/boundary predicates. `Codable` (two nullable epoch
/// days) powers `@SceneStorage`-based state survival across process death.
public struct SelectedRange: Hashable, Codable, Sendable {
  public let start: CalDate?
  public let end: CalDate?

  public init(start: CalDate? = nil, end: CalDate? = nil) {
    self.start = start
    self.end = end
  }

  /// Both endpoints picked.
  public var isComplete: Bool { start != nil && end != nil }

  /// A start is picked but the end is still pending.
  public var isPartial: Bool { start != nil && end == nil }

  /// `true` when [date] is one of the two endpoints.
  public func isEndpoint(_ date: CalDate) -> Bool { date == start || date == end }

  /// `true` when [date] falls strictly between the two endpoints.
  public func isInBetween(_ date: CalDate) -> Bool {
    guard let s = start, let e = end else { return false }
    return date.isAfter(s) && date.isBefore(e)
  }

  /// Returns a copy with `end` replaced.
  public func with(end newEnd: CalDate?) -> SelectedRange {
    SelectedRange(start: start, end: newEnd)
  }

  // MARK: @SceneStorage encoding (two nullable epoch days).

  /// Encodes the range as `"<startEpochDay>|<endEpochDay>"` (each side empty when nil).
  var sceneEncoded: String {
    "\(start.map { String($0.epochDay) } ?? "")|\(end.map { String($0.epochDay) } ?? "")"
  }

  /// Decodes a `sceneEncoded` string. Returns nil only when the string is malformed.
  init?(sceneEncoded: String) {
    let parts = sceneEncoded.split(separator: "|", omittingEmptySubsequences: false)
    guard parts.count == 2 else { return nil }
    self.init(
      start: Int(parts[0]).map { CalDate(epochDay: $0) },
      end: Int(parts[1]).map { CalDate(epochDay: $0) })
  }
}
