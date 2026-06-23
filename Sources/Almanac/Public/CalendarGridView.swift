import SwiftUI
import HorizonCalendar

/// The bare scrolling month grid — **no top bar, no footer**. Just the calendar with day selection
/// and holiday dots, for embedding in your own screen (your own title, your own Apply button, etc.).
///
/// Selection is reported via `onSelectionChange` (fires on every change). Styling
/// (`.calendarStyle`), composition (`.calendarDay`, `.calendarMonthHeader`, …) and
/// `CalendarController.scroll(to:)` all work exactly as on the full picker.
///
///     CalendarGridView(configuration: CalendarPickerConfiguration(localeTag: "tr")) { result in
///       selectedRange = result   // result.goingDate / result.returnDate
///     }
public struct CalendarGridView: View {
  @State private var viewModel: CalendarScreenViewModel
  @State private var proxy = CalendarViewProxy()
  private let controller: CalendarController?
  private let onSelectionChange: ((CalendarPickerResult) -> Void)?

  public init(
    configuration: CalendarPickerConfiguration,
    controller: CalendarController? = nil,
    onSelectionChange: ((CalendarPickerResult) -> Void)? = nil)
  {
    _viewModel = State(initialValue: configuration.makeViewModel())
    self.controller = controller
    self.onSelectionChange = onSelectionChange
  }

  public var body: some View {
    CalendarRangeSelector(viewModel: viewModel, proxy: proxy, bottomInset: 0)
      .onAppear {
        let calendar = viewModel.calendar
        proxy.scrollToMonth(
          containing: viewModel.firstVisibleMonth.yearMonth.firstDayDate(in: calendar),
          scrollPosition: .firstFullyVisiblePosition,
          animated: false)
        controller?.scrollHandler = { date, animated in
          let month = CalDate(date, in: calendar).calMonth
            .coerced(in: viewModel.startMonth.yearMonth, viewModel.endMonth.yearMonth)
          proxy.scrollToMonth(
            containing: month.firstDayDate(in: calendar),
            scrollPosition: .firstFullyVisiblePosition,
            animated: animated)
        }
      }
      .onDisappear { controller?.scrollHandler = nil }
      .onChange(of: viewModel.selectedRange) { _, newValue in
        onSelectionChange?(CalendarPickerResult(range: newValue))
      }
  }
}
