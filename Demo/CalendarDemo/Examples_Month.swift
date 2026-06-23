import SwiftUI
import Almanac

// Month-based examples (1, 2, 3, 4, 8) — all built on Almanac's `CalendarGridView` /
// `CalendarRangePickerView`.

/// Example 1 — Horizontal calendar with paged scroll and programmatic scrolling.
/// (Almanac selection is range-based; the multiple-selection of the original maps to a range here.)
struct Example1View: View {
  @StateObject private var controller = CalendarController()
  @State private var result: CalendarPickerResult?

  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Yatay takvim — ay başlığı, sayfalı kaydırma, programatik kaydırma. Aşağıdaki butonlarla aylar arasında atlayın.")

      HStack {
        Button { controller.scrollToToday() } label: {
          Label("Bugün", systemImage: "arrow.uturn.backward")
        }
        Spacer()
        Button { controller.scroll(to: DemoData.date(daysFromNow: 90)) } label: {
          Label("+3 ay", systemImage: "arrow.right")
        }
      }
      .font(.subheadline)
      .padding(.horizontal, 16)
      .padding(.vertical, 10)

      CalendarGridView(
        configuration: CalendarPickerConfiguration(
          maxSelectableDate: DemoData.date(daysFromNow: 365),
          localeTag: "tr",
          horizontalPaging: true,
          calendar: ExampleData.calendar),
        controller: controller,
        onSelectionChange: { result = $0 })
    }
    .navigationTitle("Example 1")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// Example 2 — Vertical calendar with sticky header and continuous range selection across months;
/// past days disabled. This is exactly Almanac's stock range picker (the "Airbnb" pattern).
struct Example2View: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    CalendarRangePickerView.rangeSelector(
      configuration: CalendarPickerConfiguration(
        goingDate: DemoData.date(daysFromNow: 2),
        returnDate: DemoData.date(daysFromNow: 6),
        maxSelectableDate: DemoData.date(daysFromNow: 300),
        holidays: DemoData.holidays(),
        localeTag: "tr",
        minNights: 1,
        calendar: ExampleData.calendar),
      onApply: { _ in dismiss() },
      onCancel: { dismiss() })
    .toolbar(.hidden, for: .navigationBar)
  }
}

/// Example 3 — Horizontal calendar, single selection, per-day price badges. A flight-schedule
/// calendar.
struct Example3View: View {
  @State private var result: CalendarPickerResult?

  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Yatay takvim — tek tarih seçimi, gün başına fiyat rozetli bir uçuş takvimi.")

      CalendarGridView(
        configuration: CalendarPickerConfiguration(
          maxSelectableDate: DemoData.date(daysFromNow: 200),
          localeTag: "tr",
          priceByDate: DemoData.prices(),
          selectionMode: .single,
          horizontalPaging: true,
          calendar: ExampleData.calendar),
        onSelectionChange: { result = $0 })

      SelectionLabel(date: result?.goingDate)
    }
    .navigationTitle("Example 3")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// Example 4 — Horizontal calendar with a fully custom design: custom day size/shape, custom colors
/// and a custom month header. Drives everything from one `CalendarStyle`.
struct Example4View: View {
  private let accent = Color(red: 0.10, green: 0.45, blue: 0.55)

  private var style: CalendarStyle {
    var s = CalendarStyle.standard
    s.theme.ink = accent
    s.theme.inBetweenFill = accent.opacity(0.15)
    s.theme.surface = Color(red: 0.96, green: 0.98, blue: 0.99)
    s.metrics.daySelectionShape = .roundedRectangle(cornerRadius: 8)
    s.metrics.dayCellMinSize = 44
    s.metrics.dayCellMaxSize = 58
    s.metrics.weekRowSpacing = 12
    s.typography.dayNumber.size = 17
    s.typography.dayNumber.weight = .semibold
    return s
  }

  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Yatay takvim — özel gün boyutu/şekli, özel renkler ve özel ay başlığı (tek bir CalendarStyle ile).")

      CalendarGridView(
        configuration: CalendarPickerConfiguration(
          maxSelectableDate: DemoData.date(daysFromNow: 365),
          localeTag: "tr",
          horizontalPaging: true,
          calendar: ExampleData.calendar))
      .calendarStyle(style)
      .calendarMonthHeader { month, locale in
        Text(exMonthTitle(month, locale: locale))
          .font(.title3.bold())
          .foregroundStyle(accent)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 12)
          .padding(.top, 16)
          .padding(.bottom, 8)
      }
    }
    .navigationTitle("Example 4")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// Example 8 — Fullscreen horizontal calendar with month header + footer, paged horizontal
/// scrolling. The stock picker chrome filling the whole screen.
struct Example8View: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    CalendarRangePickerView.rangeSelector(
      configuration: CalendarPickerConfiguration(
        maxSelectableDate: DemoData.date(daysFromNow: 365),
        holidays: DemoData.holidays(),
        localeTag: "tr",
        horizontalPaging: true,
        calendar: ExampleData.calendar),
      onApply: { _ in dismiss() },
      onCancel: { dismiss() })
    .toolbar(.hidden, for: .navigationBar)
  }
}
