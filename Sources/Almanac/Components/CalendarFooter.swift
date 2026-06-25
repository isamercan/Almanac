import SwiftUI

/// Reports the footer's measured height back to the screen, used as the calendar's bottom
/// content inset.
struct FooterHeightKey: PreferenceKey {
  static let defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

/// Reports the selected-date accessory's measured height (0 when absent); added to the bottom inset.
struct AccessoryHeightKey: PreferenceKey {
  static let defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

/// Bottom panel: animated legend + Clear/Apply buttons. /// — rounded top corners, shadow, pill buttons. It sits within the bottom
/// safe area; the screen's background fills the area beneath it (home-indicator zone).
struct CalendarFooter: View {
  let holidayCategories: [HolidayCategory]
  var locale: Locale = .current
  var onClear: () -> Void
  var onApply: () -> Void
  var clearEnabled: Bool = true
  var applyEnabled: Bool = true
  var showsLegend: Bool = true
  var showsClearButton: Bool = true
  var showsApplyButton: Bool = true
  @Environment(\.calendarStyle) private var style
  @Environment(\.calendarContent) private var content

  private var theme: CalendarTheme { style.theme }
  private var metrics: CalendarMetrics { style.metrics }

  private var footerShape: UnevenRoundedRectangle {
    UnevenRoundedRectangle(
      topLeadingRadius: metrics.footerCornerRadius,
      bottomLeadingRadius: 0,
      bottomTrailingRadius: 0,
      topTrailingRadius: metrics.footerCornerRadius)
  }

  var body: some View {
    VStack(spacing: 0) {
      if showsLegend {
        if let custom = content.legend {
          custom(holidayCategories)
        } else {
          HolidayLegend(categories: holidayCategories)
        }
        Spacer().frame(height: metrics.footerContentSpacing)
      }

      if showsClearButton || showsApplyButton {
        HStack(spacing: metrics.buttonSpacing) {
          if showsClearButton { clearButton }
          if showsApplyButton { applyButton }
        }
      }
    }
    .padding(.horizontal, metrics.footerHorizontalPadding)
    .padding(.vertical, metrics.footerVerticalPadding)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(theme.surface, in: footerShape)
    .shadow(color: .black.opacity(0.12), radius: metrics.footerShadowRadius, y: -2)
    .background(
      GeometryReader { inner in
        Color.clear.preference(key: FooterHeightKey.self, value: inner.size.height)
      })
  }

  // MARK: Buttons

  private var clearButton: some View {
    Button(action: onClear) {
      Text(L10n.string(L10n.Key.clear, locale: locale))
        .calendarTextStyle(style.typography.button)
        .foregroundStyle(clearEnabled ? theme.ink : theme.disabledButtonContent)
        .frame(maxWidth: .infinity)
        .frame(height: metrics.buttonHeight)
        .background(clearEnabled ? theme.surface : theme.disabledButtonContainer, in: Capsule())
        .overlay(
          Capsule().stroke(
            clearEnabled ? theme.ink : theme.ink.opacity(0.1),
            lineWidth: metrics.buttonBorderWidth))
    }
    .buttonStyle(.plain)
    .disabled(!clearEnabled)
    .accessibilityIdentifier("calendar.clear")
  }

  private var applyButton: some View {
    Button(action: onApply) {
      Text(L10n.string(L10n.Key.apply, locale: locale))
        .calendarTextStyle(style.typography.button)
        .foregroundStyle(applyEnabled ? theme.onInk : theme.disabledButtonContent)
        .frame(maxWidth: .infinity)
        .frame(height: metrics.buttonHeight)
        .background(applyEnabled ? theme.ink : theme.disabledButtonContainer, in: Capsule())
    }
    .buttonStyle(.plain)
    .disabled(!applyEnabled)
    .accessibilityIdentifier("calendar.apply")
  }
}
