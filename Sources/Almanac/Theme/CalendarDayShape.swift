import SwiftUI

/// The shape used for a day's selection fill, today ring and same-day ring.
public enum CalendarDayShape: Equatable, Sendable {
  /// A full circle (the default).
  case circle
  /// A rounded rectangle with the given corner radius.
  case roundedRectangle(cornerRadius: CGFloat)
  /// A plain square (sharp corners).
  case square

  /// Type-erased SwiftUI shape.
  public var anyShape: AnyShape {
    switch self {
    case .circle: AnyShape(Circle())
    case .roundedRectangle(let radius): AnyShape(RoundedRectangle(cornerRadius: radius))
    case .square: AnyShape(Rectangle())
    }
  }
}
