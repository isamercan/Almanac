import SwiftUI
import Almanac

// Variant examples present in the sample source but not as separate menu entries:
// Example 2 "Highlight" and Example 9 "AnimatedVisibility".

/// Example 2 (variant) — "Highlight" continuous-selection style (modern Airbnb look): a connected
/// bar behind the in-range days with circular endpoints, drawn via `.calendarDay`.
struct Example2HighlightView: View {
  @State private var result: CalendarPickerResult?

  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Dikey takvim — modern Airbnb 'highlight' sürekli aralık stili: aralığın arkasında bağlı bir vurgu çubuğu ve yuvarlak uç noktalar.")

      CalendarGridView(
        configuration: CalendarPickerConfiguration(
          goingDate: DemoData.date(daysFromNow: 2),
          returnDate: DemoData.date(daysFromNow: 6),
          maxSelectableDate: DemoData.date(daysFromNow: 300),
          localeTag: "tr",
          calendar: ExampleData.calendar),
        onSelectionChange: { result = $0 })
      .calendarDay { ctx in HighlightDayCell(context: ctx) }
    }
    .navigationTitle("Example 2 · Highlight")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// A day cell drawing the continuous "highlight" range bar with circular endpoints.
private struct HighlightDayCell: View {
  let context: CalendarDayContext
  private let theme = CalendarTheme.standard

  /// The bar reaches the leading edge for in-between days and for the range end.
  private var leadingBarFilled: Bool {
    context.isInBetween || (context.isRangeEnd && !context.isSameDay)
  }
  /// The bar reaches the trailing edge for in-between days and for the range start.
  private var trailingBarFilled: Bool {
    context.isInBetween || (context.isRangeStart && !context.isSameDay)
  }

  var body: some View {
    ZStack {
      // Continuous highlight bar (connects across adjacent cells).
      HStack(spacing: 0) {
        Rectangle().fill(leadingBarFilled ? theme.inBetweenFill : Color.clear)
        Rectangle().fill(trailingBarFilled ? theme.inBetweenFill : Color.clear)
      }
      .frame(height: 36)

      // Circular endpoint for the start / end / single day.
      if context.isSelected {
        Circle().fill(theme.ink).frame(width: 36, height: 36)
      }

      Text("\(context.day)")
        .font(.system(size: 15, weight: context.isSelected ? .semibold : .regular))
        .foregroundStyle(
          context.isSelected ? theme.onInk
            : (context.isDisabled ? Color.secondary : theme.ink))
    }
    .frame(maxWidth: .infinity)
    .frame(height: 44)
    .opacity(context.isDisabled && !context.isSelected ? 0.4 : 1)
  }
}

/// Example 9 (variant) — month ↔ week toggle in the "AnimatedVisibility" style: the week strip
/// stays visible while the month grid expands / collapses with animation.
struct Example9AnimatedView: View {
  @State private var weekMode = false
  @State private var selected: Date?
  private let days = ExampleData.upcomingDays(60)

  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Ay ↔ hafta geçişi (AnimatedVisibility tarzı): hafta şeridi sabit kalır, ay görünümü animasyonla açılıp kapanır.")

      Toggle("Hafta modu", isOn: $weekMode.animation(.easeInOut))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)

      // Week strip — always visible.
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 4) {
          ForEach(days, id: \.self) { day in
            WeekDayCell(date: day, isSelected: exIsSameDay(day, selected), isToday: exIsToday(day), width: 56)
              .onTapGesture { withAnimation { selected = day } }
          }
        }
        .padding(12)
      }
      .frame(height: 100)
      Divider()

      // Month grid — animates in / out.
      if !weekMode {
        CalendarGridView(
          configuration: CalendarPickerConfiguration(
            maxSelectableDate: DemoData.date(daysFromNow: 200),
            localeTag: "tr",
            selectionMode: .single,
            calendar: ExampleData.calendar),
          onSelectionChange: { selected = $0.goingDate })
        .transition(.opacity.combined(with: .move(edge: .bottom)))
      } else {
        SelectionLabel(date: selected)
        Spacer()
      }
    }
    .navigationTitle("Example 9 · Animated")
    .navigationBarTitleDisplayMode(.inline)
  }
}
