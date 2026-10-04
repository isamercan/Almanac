import SwiftUI

private let flipHeight: CGFloat = 24            // approximates the label height for the drum offset

/// Top bar: back / centered "Select Date" title / close, a divider, then the
/// departure → arrow → return row with the odometer flip. Icons use SF Symbols.
struct CalendarTopBar: View {
  let departureDate: SelectedDay
  let returnDate: SelectedDay
  var locale: Locale = .current
  var calendar: Calendar = CalendarMath.gregorian
  var onBack: () -> Void
  var onClose: () -> Void
  var onClearReturn: () -> Void = {}
  /// Optional placeholder titles overriding the default departure/return prompts
  /// (leave `nil` to keep the defaults).
  var startDateEmptyTitle: String? = nil
  var endDateEmptyTitle: String? = nil
  var isDismissEndEnabled: Bool = true
  var showPlusIconForReturn: Bool = true
  /// When false (single-date mode), only the departure label is shown — no arrow / return area.
  var showsReturn: Bool = true
  /// Show the back/title/close row (+ divider).
  var showsTitleBar: Bool = true
  /// Show the departure → return summary row.
  var showsDateRow: Bool = true
  /// The title in place of the bundled "Select Date"; nil keeps it.
  var title: String? = nil
  /// A fixed date pattern for the row; nil ⇒ the locale's long style.
  var dateFormat: String? = nil
  @Environment(\.calendarStyle) private var style
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var departureLabel: String? {
    departureDate.date.map { CalendarFormatting.longDate($0, locale: locale, calendar: calendar, format: dateFormat) }
  }
  private var returnLabel: String? {
    returnDate.date.map { CalendarFormatting.longDate($0, locale: locale, calendar: calendar, format: dateFormat) }
  }

  var body: some View {
    VStack(spacing: 0) {
      if showsTitleBar {
        // Title row
        HStack(spacing: 0) {
          iconButton(systemName: "chevron.left", boxSize: 32, iconSize: style.metrics.topBarBackIconSize,
                     accessibility: L10n.string(L10n.Key.back, locale: locale),
                     identifier: "calendar.back", action: onBack)
          Text(title ?? L10n.string(L10n.Key.selectDatePrompt, locale: locale))
            .calendarTextStyle(style.typography.topBarTitle)
            .foregroundStyle(style.theme.ink)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
          iconButton(systemName: "xmark", boxSize: 20, iconSize: style.metrics.topBarCloseIconSize,
                     accessibility: L10n.string(L10n.Key.close, locale: locale),
                     identifier: "calendar.close", action: onClose)
        }
        .frame(height: style.metrics.topBarHeight)
        .padding(.horizontal, style.metrics.topBarHorizontalPadding)

        // 1dp divider
        Rectangle()
          .fill(style.theme.line)
          .frame(height: style.metrics.dividerHeight)
          .frame(maxWidth: .infinity)
      }

      // Departure (/ return) row
      if showsDateRow {
        dateRow
      }
    }
    .frame(maxWidth: .infinity)
    .background(style.theme.surface)
  }

  @ViewBuilder private var dateRow: some View {
    Group {
      if showsReturn {
        HStack(spacing: 0) {
          departureView
            .frame(maxWidth: .infinity, alignment: isEdges ? .leading : .center)

          Image(systemName: "arrow.right")
            .resizable()
            .scaledToFit()
            .frame(width: 20)
            .foregroundStyle(style.theme.ink)
            .frame(width: 24, height: 24)

          returnView
            .frame(maxWidth: .infinity, alignment: isEdges ? .trailing : .center)
        }
        .padding(.vertical, style.metrics.dateRowVerticalPadding)
        .padding(.horizontal, style.metrics.dateRowHorizontalPadding)
      } else {
        departureView
          .frame(maxWidth: .infinity, alignment: isEdges ? .leading : .center)
          .padding(.vertical, style.metrics.dateRowVerticalPadding)
          .padding(.horizontal, style.metrics.dateRowHorizontalPadding)
      }
    }
    .frame(maxWidth: .infinity)
    .background(style.theme.surface)
  }

  private var isEdges: Bool { style.metrics.dateRowAlignment == .edges }

  // MARK: Departure (flips on change)

  private var departureView: some View {
    let placeholder = startDateEmptyTitle ?? L10n.string(L10n.Key.departureDate, locale: locale)
    let label = departureLabel ?? placeholder
    return ZStack {
      Text(label)
        .calendarTextStyle(style.typography.dateLabel)
        .foregroundStyle(style.theme.ink)
        .frame(maxWidth: .infinity, alignment: isEdges ? .leading : .center)
        .multilineTextAlignment(isEdges ? .leading : .center)
        .id(label)
        .transition(.drumFlip)
    }
    .animation(reduceMotion ? nil : .easeInOut(duration: style.metrics.dateFlipDuration), value: label)
  }

  // MARK: Return (plus / label / dismiss, flips on change)

  private var returnView: some View {
    let placeholder = endDateEmptyTitle ?? L10n.string(L10n.Key.addReturn, locale: locale)
    let label = returnLabel ?? placeholder
    let showDismiss = (returnLabel != nil) && isDismissEndEnabled
    let showPlus = (returnLabel == nil) && showPlusIconForReturn

    return ZStack {
      HStack(spacing: 0) {
        if showPlus {
          Image(systemName: "plus")
            .resizable().scaledToFit().frame(width: 16)
            .foregroundStyle(style.theme.ink)
            .frame(width: 20, height: 20)
          Spacer().frame(width: 4)
        }
        Text(label)
          .calendarTextStyle(style.typography.dateLabel)
          .foregroundStyle(style.theme.ink)
        if showDismiss {
          Spacer().frame(width: 4)
          Button(action: onClearReturn) {
            Image(systemName: style.metrics.returnClearIconFilled ? "xmark.circle.fill" : "xmark.circle")
              .resizable().scaledToFit().frame(width: 16)
              .foregroundStyle(style.theme.ink)
              .frame(width: 24, height: 24)
          }
          .buttonStyle(.plain)
          .accessibilityLabel(L10n.string(L10n.Key.clearReturnDate, locale: locale))
        }
      }
      .frame(maxWidth: .infinity, alignment: isEdges ? .trailing : .center)
      .id("\(label)#\(showDismiss)#\(showPlus)")
      .transition(.drumFlip)
    }
    .animation(reduceMotion ? nil : .easeInOut(duration: style.metrics.dateFlipDuration), value: label)
  }

  // MARK: Helpers

  private func iconButton(
    systemName: String, boxSize: CGFloat, iconSize: CGFloat,
    accessibility: String, identifier: String, action: @escaping () -> Void) -> some View
  {
    Button(action: action) {
      Image(systemName: systemName)
        .resizable()
        .scaledToFit()
        .frame(width: iconSize)
        .foregroundStyle(style.theme.ink)
        .frame(width: boxSize, height: boxSize)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel(accessibility)
    .accessibilityIdentifier(identifier)
  }
}

// MARK: - Drum flip transition (rotationX odometer)

private struct DrumFlipModifier: ViewModifier {
  /// PreEnter = 1, Visible = 0, PostExit = -1 — representing the transition fraction.
  let fraction: CGFloat
  func body(content: Content) -> some View {
    content
      .rotation3DEffect(.degrees(Double(fraction) * -100), axis: (x: 1, y: 0, z: 0), perspective: 0.25)
      .offset(y: fraction * flipHeight)
  }
}

private extension AnyTransition {
  /// Old content rotates up and out; new content rotates in from below. Alpha stays pinned
  /// to 1, so there is no actual fade.
  static var drumFlip: AnyTransition {
    .asymmetric(
      insertion: .modifier(active: DrumFlipModifier(fraction: 1), identity: DrumFlipModifier(fraction: 0)),
      removal: .modifier(active: DrumFlipModifier(fraction: -1), identity: DrumFlipModifier(fraction: 0)))
  }
}
