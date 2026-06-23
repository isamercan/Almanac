import SwiftUI
import Almanac

// HeatMap (6) and year-calendar (10, 11) examples.

/// Example 6 — HeatMap calendar (GitHub-contributions style). Uses `CalendarGridView` with a custom
/// `.calendarDay` that colors each cell by its activity level, with continuous vertical scroll.
struct Example6View: View {
  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Isı haritası takvimi — gün başına yoğunluk renklendirmesi (GitHub katkı grafiği tarzı), sürekli kaydırma.")

      CalendarGridView(
        configuration: CalendarPickerConfiguration(
          maxSelectableDate: DemoData.date(daysFromNow: 250),
          localeTag: "tr",
          calendar: ExampleData.calendar))
      .calendarDay { ctx in
        HeatCell(date: ctx.date, day: ctx.day, inMonth: ctx.isCurrentMonth)
      }
    }
    .navigationTitle("Example 6")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// A single heat-map day square: green intensity scales with the day's activity level.
private struct HeatCell: View {
  let date: Date
  let day: Int
  let inMonth: Bool

  var body: some View {
    let level = ExampleData.heat(for: date)
    RoundedRectangle(cornerRadius: 4)
      .fill(Color.green.opacity(inMonth ? (0.12 + level * 0.78) : 0.05))
      .frame(maxWidth: .infinity)
      .frame(height: 30)
      .overlay(
        Text("\(day)")
          .font(.system(size: 9, weight: .medium))
          .foregroundStyle(level > 0.6 && inMonth ? .white : .secondary))
      .padding(1)
  }
}

/// Example 10 — Horizontal year calendar with paged scrolling (swipe between years).
struct Example10View: View {
  private let years = [2026, 2027, 2028]

  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Yatay yıl takvimi — yıllar arasında sayfalı kaydırma. Büyük ekranlar için uygundur.")

      TabView {
        ForEach(years, id: \.self) { year in
          VStack(spacing: 8) {
            Text(String(year))
              .font(.title2.bold())
              .padding(.top, 8)
            CalendarYearView(year: year, locale: Locale(identifier: "tr"))
          }
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .always))
    }
    .navigationTitle("Example 10")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// Example 11 — Vertical year calendar with continuous scroll (all 12 months in one flow).
struct Example11View: View {
  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Dikey yıl takvimi — 12 ay tek akışta, sürekli kaydırma. Büyük ekranlar için uygundur.")

      CalendarYearView(year: 2026, locale: Locale(identifier: "tr"))
    }
    .navigationTitle("Example 11")
    .navigationBarTitleDisplayMode(.inline)
  }
}
