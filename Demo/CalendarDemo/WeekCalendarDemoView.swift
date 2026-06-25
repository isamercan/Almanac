import SwiftUI
import Almanac

/// Showcases the first-class `CalendarWeekView` — a paged week strip with the full selection
/// machinery (range or single), holidays, price badges and theming, plus programmatic paging via a
/// `CalendarController`.
struct WeekCalendarDemoView: View {
  let configuration: CalendarPickerConfiguration

  @StateObject private var controller = CalendarController()
  @State private var resultText = "—"

  var body: some View {
    VStack(spacing: 0) {
      CalendarWeekView(configuration: configuration, controller: controller) { result in
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: configuration.localeTag ?? "tr")
        let going = result.goingDate.map(formatter.string(from:)) ?? "—"
        let ret = result.returnDate.map(formatter.string(from:)) ?? "—"
        resultText = "Gidiş: \(going)   •   Dönüş: \(ret)"
      }

      Divider()
      Text(resultText)
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
      Spacer()
    }
    .navigationTitle("Hafta Takvimi")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Bugün") { controller.scrollToToday() }
      }
    }
  }
}

#Preview {
  NavigationStack {
    WeekCalendarDemoView(
      configuration: CalendarPickerConfiguration(localeTag: "tr", selectionMode: .single))
  }
}
