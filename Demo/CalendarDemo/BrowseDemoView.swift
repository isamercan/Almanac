import SwiftUI
import Almanac

/// Showcases three new pieces together:
///  • `CalendarBrowseView` — year overview ↔ month grid navigation (tap a month to zoom in).
///  • `CalendarThemePreset` — swap named palettes live.
///  • `.calendarSelectedDateAccessory` — a detail card shown above the grid for the selected day.
struct BrowseDemoView: View {
  let configuration: CalendarPickerConfiguration

  @State private var preset: CalendarThemePreset = .ocean
  @State private var lastSelected: Date?

  private var localeTag: String { configuration.localeTag ?? "tr" }

  var body: some View {
    VStack(spacing: 0) {
      Picker("Tema", selection: $preset) {
        ForEach(CalendarThemePreset.allCases) { p in
          Text(p.displayName).tag(p)
        }
      }
      .pickerStyle(.segmented)
      .padding()

      CalendarBrowseView(configuration: configuration) { result in
        lastSelected = result.returnDate ?? result.goingDate
      }
      .calendarTheme(preset.theme)
      .calendarSelectedDateAccessory { date in
        HStack(spacing: 10) {
          Image(systemName: "calendar.badge.checkmark")
          Text(longDate(date))
            .font(.system(size: 15, weight: .semibold))
          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(preset.theme.inBetweenFill)
      }
    }
    .navigationTitle("Browse + Tema + Accessory")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func longDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.calendar = configuration.calendar
    formatter.locale = Locale(identifier: localeTag)
    formatter.dateStyle = .full
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }
}

#Preview {
  NavigationStack {
    BrowseDemoView(configuration: CalendarPickerConfiguration(localeTag: "tr"))
  }
}
