import SwiftUI

/// Animated legend. each category fades + expands in
/// when it appears and fades + collapses out when it leaves, so the footer grows/shrinks smoothly.
/// Items are identified by `legendKey` (description + color) and ordered by `sortKey`.
///
/// SwiftUI animates insertions/removals via the `.opacity` transition; the surrounding column's
/// height change is animated by `.animation(value:)`, giving the per-item expand/collapse feel.
struct HolidayLegend: View {
  let categories: [HolidayCategory]
  @Environment(\.calendarStyle) private var style
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var sorted: [HolidayCategory] { categories.sorted { $0.sortKey < $1.sortKey } }

  var body: some View {
    VStack(alignment: .leading, spacing: style.metrics.legendItemSpacing) {
      ForEach(sorted) { category in
        HStack(spacing: 8) {
          Circle()
            .fill(category.color)
            .frame(width: style.metrics.legendDotSize, height: style.metrics.legendDotSize)
          Text(category.categoryDescription)
            .calendarTextStyle(style.typography.legend)
            .foregroundStyle(style.theme.ink)
        }
        .transition(.opacity)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: sorted)
  }
}
