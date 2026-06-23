import SwiftUI

/// A single day cell. /// base number, today ring, animated selection/in-between circle, same-day inner ring, holiday dot,
/// optional price badge. Rendered inside HorizonCalendar's `.days { }` provider.
///
/// `style` is passed explicitly (not read from the environment) because HorizonCalendar hosts each
/// day view in its own hosting controller, which does not inherit the SwiftUI environment.
struct CalendarDayIndicator: View {
  let day: Int
  let isSelected: Bool
  let isToday: Bool
  let isHoliday: Bool
  var isInBetween: Bool = false
  var isSameDay: Bool = false
  var isDisabled: Bool = false
  var holidayIndicatorColor: Color = CalendarColors.holidayDot
  var badge: String? = nil
  var style: CalendarStyle = .standard
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var theme: CalendarTheme { style.theme }
  private var metrics: CalendarMetrics { style.metrics }

  private var active: Bool { isSelected || isInBetween }
  private var circleColor: Color { isSelected ? theme.ink : theme.inBetweenFill }
  private var textColor: Color {
    if isSelected { return theme.onInk }
    return isDisabled ? theme.line : theme.ink
  }

  private var selectionShape: AnyShape { metrics.daySelectionShape.anyShape }

  private var daySquare: some View {
    ZStack {
      if isToday && !isSelected && !isInBetween {
        selectionShape.stroke(theme.todayRing, lineWidth: metrics.todayRingWidth)
      }

      selectionShape
        .fill(active ? circleColor : .clear)
        .scaleEffect(active ? 1 : 0)
        .opacity(active ? 1 : 0)

      if isSameDay {
        selectionShape
          .stroke(theme.onInk, lineWidth: metrics.sameDayRingWidth)
          .padding(3)
          .scaleEffect(active ? 1 : 0)
          .opacity(active ? 1 : 0)
      }

      Text("\(day)")
        .calendarTextStyle(style.typography.dayNumber)
        .foregroundStyle(textColor)
    }
    .frame(
      minWidth: metrics.dayCellMinSize, maxWidth: metrics.dayCellMaxSize,
      minHeight: metrics.dayCellMinSize, maxHeight: metrics.dayCellMaxSize)
    .aspectRatio(1, contentMode: .fit)
    .overlay(alignment: .bottom) {
      if isHoliday {
        Circle()
          .fill(holidayIndicatorColor)
          .frame(width: metrics.holidayDotSize, height: metrics.holidayDotSize)
          .padding(.bottom, metrics.holidayDotBottomPadding)
      }
    }
  }

  var body: some View {
    VStack(spacing: 1) {
      daySquare
      if let badge {
        Text(badge)
          .font(.system(size: metrics.badgeFontSize, weight: .medium))
          .foregroundStyle(isDisabled ? theme.line : theme.ink)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(theme.surface)
    .contentShape(Rectangle())
    .animation(reduceMotion ? nil : .easeInOut(duration: metrics.selectionAnimationDuration), value: active)
  }
}

#Preview {
  HStack(spacing: 2) {
    ForEach(20...26, id: \.self) { d in
      CalendarDayIndicator(
        day: d,
        isSelected: d == 21 || d == 25,
        isToday: d == 20,
        isHoliday: (22...25).contains(d),
        isInBetween: (22...24).contains(d))
    }
  }
  .frame(height: 56)
  .padding()
  .background(CalendarColors.surface)
}
