import SwiftUI
import Almanac

/// Shows the 12-month `CalendarYearView`; tapping a month opens the range picker and uses
/// `CalendarController.scroll(to:)` to jump straight to that month.
struct YearOverviewDemoView: View {
  let configuration: CalendarPickerConfiguration

  @StateObject private var controller = CalendarController()
  @State private var pendingMonth: CalMonth?
  @State private var showPicker = false

  var body: some View {
    CalendarYearView(year: 2026, locale: Locale(identifier: "tr")) { month in
      pendingMonth = month
      showPicker = true
    }
    .navigationTitle("2026")
    .navigationBarTitleDisplayMode(.inline)
    .fullScreenCover(isPresented: $showPicker) {
      CalendarRangePickerView(
        configuration: configuration,
        controller: controller,
        onApply: { _ in showPicker = false },
        onCancel: { showPicker = false })
      .onAppear {
        guard let month = pendingMonth,
              let date = Calendar.current.date(
                from: DateComponents(year: month.year, month: month.month, day: 1))
        else { return }
        // Defer so the calendar has laid out before scrolling.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          controller.scroll(to: date, animated: false)
        }
      }
    }
  }
}
