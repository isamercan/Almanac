import SwiftUI
import Almanac

// Week-based examples (5, 7, 9). A single-week strip isn't one of Almanac's built-in layouts, so
// these are small SwiftUI views themed with Almanac's `CalendarTheme` to match the month views.

/// Example 5 — Week calendar with paged scroll and single selection.
struct Example5View: View {
  @State private var selected: Date? = ExampleData.calendar.startOfDay(for: Date())
  private let weeks = ExampleData.mondays(8)

  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Hafta takvimi — tek tarih seçimi, sayfalı kaydırma (yana kaydırarak haftalar arasında geçin).")

      TabView {
        ForEach(weeks, id: \.self) { monday in
          HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { offset in
              if let day = ExampleData.calendar.date(byAdding: .day, value: offset, to: monday) {
                WeekDayCell(date: day, isSelected: exIsSameDay(day, selected), isToday: exIsToday(day))
                  .frame(maxWidth: .infinity)
                  .onTapGesture { withAnimation { selected = day } }
              }
            }
          }
          .padding(.horizontal, 8)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .automatic))
      .frame(height: 120)

      Divider()
      SelectionLabel(date: selected)
      Spacer()
    }
    .navigationTitle("Example 5")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// Example 7 — Week calendar with continuous horizontal scroll, custom day width, single selection.
struct Example7View: View {
  @State private var selected: Date?
  private let days = ExampleData.upcomingDays(60)

  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Hafta takvimi — sürekli yatay kaydırma, özel gün genişliği, tek tarih seçimi.")

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 4) {
          ForEach(days, id: \.self) { day in
            WeekDayCell(date: day, isSelected: exIsSameDay(day, selected), isToday: exIsToday(day), width: 64)
              .onTapGesture { withAnimation { selected = day } }
          }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
      }

      Divider()
      SelectionLabel(date: selected)
      Spacer()
    }
    .navigationTitle("Example 7")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// Example 9 — Animated toggle between a month calendar and a week calendar.
struct Example9View: View {
  private enum Mode: Hashable { case month, week }
  @State private var mode: Mode = .month
  @State private var selected: Date?
  private let days = ExampleData.upcomingDays(60)

  var body: some View {
    VStack(spacing: 0) {
      ExampleCaption("Animasyonlu ay ↔ hafta takvimi geçişi.")

      Picker("", selection: $mode.animation(.easeInOut)) {
        Text("Ay").tag(Mode.month)
        Text("Hafta").tag(Mode.week)
      }
      .pickerStyle(.segmented)
      .padding(16)

      if mode == .month {
        CalendarGridView(
          configuration: CalendarPickerConfiguration(
            maxSelectableDate: DemoData.date(daysFromNow: 200),
            localeTag: "tr",
            selectionMode: .single,
            calendar: ExampleData.calendar),
          onSelectionChange: { selected = $0.goingDate })
        .transition(.move(edge: .bottom).combined(with: .opacity))
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(spacing: 4) {
            ForEach(days, id: \.self) { day in
              WeekDayCell(date: day, isSelected: exIsSameDay(day, selected), isToday: exIsToday(day), width: 60)
                .onTapGesture { withAnimation { selected = day } }
            }
          }
          .padding(12)
        }
        .frame(height: 110)
        .transition(.move(edge: .top).combined(with: .opacity))
        SelectionLabel(date: selected)
        Spacer()
      }
    }
    .navigationTitle("Example 9")
    .navigationBarTitleDisplayMode(.inline)
  }
}
