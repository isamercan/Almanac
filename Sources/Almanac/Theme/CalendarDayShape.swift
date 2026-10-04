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
  @available(iOS 16, *)
  public var anyShape: AnyShape {
    switch self {
    case .circle: AnyShape(Circle())
    case .roundedRectangle(let radius): AnyShape(RoundedRectangle(cornerRadius: radius))
    case .square: AnyShape(Rectangle())
    }
  }
}


/// The day shape as a concrete `Shape`, for every iOS version (`AnyShape` needs iOS 16).
struct CalendarDayShapeView: Shape {
  let kind: CalendarDayShape

  func path(in rect: CGRect) -> Path {
    switch kind {
    case .circle: return Circle().path(in: rect)
    case .roundedRectangle(let radius): return RoundedRectangle(cornerRadius: radius).path(in: rect)
    case .square: return Rectangle().path(in: rect)
    }
  }
}
