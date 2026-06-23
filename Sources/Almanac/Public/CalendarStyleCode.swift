import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public extension CalendarStyle {
  /// Swift source that reconstructs this style — emits only the fields that differ from
  /// `.standard`, so you can configure visually and paste the result into your app.
  var generatedSwiftCode: String {
    let std = CalendarStyle.standard
    var lines = ["var style = CalendarStyle.standard"]

    // Colors
    func color(_ keyPath: KeyPath<CalendarTheme, Color>, _ name: String) {
      if theme[keyPath: keyPath].argbValue != std.theme[keyPath: keyPath].argbValue {
        lines.append("style.theme.\(name) = \(Self.colorLiteral(theme[keyPath: keyPath]))")
      }
    }
    color(\.ink, "ink"); color(\.onInk, "onInk"); color(\.surface, "surface"); color(\.line, "line")
    color(\.weekendText, "weekendText"); color(\.todayRing, "todayRing")
    color(\.inBetweenFill, "inBetweenFill"); color(\.holidayDot, "holidayDot")
    color(\.disabledButtonContainer, "disabledButtonContainer")
    color(\.disabledButtonContent, "disabledButtonContent")

    // Typography
    func typo(_ keyPath: KeyPath<CalendarTypography, CalendarTextStyle>, _ name: String) {
      let cur = typography[keyPath: keyPath], def = std.typography[keyPath: keyPath]
      if cur.size != def.size { lines.append("style.typography.\(name).size = \(Self.num(cur.size))") }
      if cur.weight != def.weight { lines.append("style.typography.\(name).weight = \(Self.weightName(cur.weight))") }
      if cur.tracking != def.tracking { lines.append("style.typography.\(name).tracking = \(Self.num(cur.tracking))") }
    }
    typo(\.dayNumber, "dayNumber"); typo(\.monthTitle, "monthTitle"); typo(\.weekdayLabel, "weekdayLabel")
    typo(\.topBarTitle, "topBarTitle"); typo(\.dateLabel, "dateLabel"); typo(\.button, "button")
    typo(\.legend, "legend")

    // Day shape
    if metrics.daySelectionShape != std.metrics.daySelectionShape {
      lines.append("style.metrics.daySelectionShape = \(Self.shapeLiteral(metrics.daySelectionShape))")
    }

    // Metrics (CGFloat)
    func metric(_ keyPath: KeyPath<CalendarMetrics, CGFloat>, _ name: String) {
      if metrics[keyPath: keyPath] != std.metrics[keyPath: keyPath] {
        lines.append("style.metrics.\(name) = \(Self.num(metrics[keyPath: keyPath]))")
      }
    }
    metric(\.dayCellMinSize, "dayCellMinSize"); metric(\.dayCellMaxSize, "dayCellMaxSize")
    metric(\.todayRingWidth, "todayRingWidth"); metric(\.sameDayRingWidth, "sameDayRingWidth")
    metric(\.holidayDotSize, "holidayDotSize"); metric(\.holidayDotBottomPadding, "holidayDotBottomPadding")
    metric(\.badgeFontSize, "badgeFontSize"); metric(\.horizontalPadding, "horizontalPadding")
    metric(\.weekRowSpacing, "weekRowSpacing"); metric(\.interMonthSpacing, "interMonthSpacing")
    metric(\.dayAspectRatio, "dayAspectRatio"); metric(\.dayAspectRatioWithBadges, "dayAspectRatioWithBadges")
    metric(\.monthHeaderTopPadding, "monthHeaderTopPadding"); metric(\.monthHeaderBottomPadding, "monthHeaderBottomPadding")
    metric(\.topBarHeight, "topBarHeight"); metric(\.topBarHorizontalPadding, "topBarHorizontalPadding")
    metric(\.dateRowVerticalPadding, "dateRowVerticalPadding"); metric(\.dividerHeight, "dividerHeight")
    metric(\.footerCornerRadius, "footerCornerRadius"); metric(\.footerShadowRadius, "footerShadowRadius")
    metric(\.footerHorizontalPadding, "footerHorizontalPadding"); metric(\.footerVerticalPadding, "footerVerticalPadding")
    metric(\.footerContentSpacing, "footerContentSpacing"); metric(\.buttonHeight, "buttonHeight")
    metric(\.buttonSpacing, "buttonSpacing"); metric(\.buttonBorderWidth, "buttonBorderWidth")
    metric(\.legendDotSize, "legendDotSize"); metric(\.legendItemSpacing, "legendItemSpacing")

    // Metrics (Double)
    if metrics.selectionAnimationDuration != std.metrics.selectionAnimationDuration {
      lines.append("style.metrics.selectionAnimationDuration = \(Self.num(metrics.selectionAnimationDuration))")
    }
    if metrics.dateFlipDuration != std.metrics.dateFlipDuration {
      lines.append("style.metrics.dateFlipDuration = \(Self.num(metrics.dateFlipDuration))")
    }

    if lines.count == 1 { lines.append("// (varsayılan — değişiklik yok)") }
    return lines.joined(separator: "\n")
  }

  // MARK: Helpers

  private static func num(_ value: CGFloat) -> String { String(format: "%g", Double(value)) }
  private static func num(_ value: Double) -> String { String(format: "%g", value) }

  private static func shapeLiteral(_ shape: CalendarDayShape) -> String {
    switch shape {
    case .circle: return ".circle"
    case .roundedRectangle(let radius): return ".roundedRectangle(cornerRadius: \(num(radius)))"
    case .square: return ".square"
    }
  }

  private static func weightName(_ weight: Font.Weight) -> String {
    switch weight {
    case .ultraLight: return ".ultraLight"
    case .thin: return ".thin"
    case .light: return ".light"
    case .regular: return ".regular"
    case .medium: return ".medium"
    case .semibold: return ".semibold"
    case .bold: return ".bold"
    case .heavy: return ".heavy"
    case .black: return ".black"
    default: return ".regular"
    }
  }

  private static func colorLiteral(_ color: Color) -> String {
    #if canImport(UIKit)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
    return String(format: "Color(.sRGB, red: %.3f, green: %.3f, blue: %.3f, opacity: %.3f)", r, g, b, a)
    #else
    return "Color.primary"
    #endif
  }
}
