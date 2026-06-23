import SwiftUI
import HorizonCalendar

/// Full range-picker screen: top bar, vertical calendar, footer. Selection state lives in
/// `CalendarScreenViewModel` (the hoisted state + state machine); the footer's measured height
/// becomes the calendar's bottom content inset.
///
/// All inputs are already parsed/resolved by the caller (see `CalendarRangePickerView`), so this
/// view stays host-agnostic and previewable.
struct CalendarScreen: View {
  let viewModel: CalendarScreenViewModel
  var controller: CalendarController? = nil
  var onBack: () -> Void
  var onClose: () -> Void
  var onApply: (SelectedRange) -> Void

  @Environment(\.calendarStyle) private var style
  @State private var proxy = CalendarViewProxy()
  @State private var footerHeight: CGFloat = 0

  var body: some View {
    let chrome = viewModel.chrome
    VStack(spacing: 0) {
      if chrome.showsTopBar {
        CalendarTopBar(
          departureDate: SelectedDay(viewModel.selectedRange.start),
          returnDate: SelectedDay(viewModel.selectedRange.end),
          locale: viewModel.locale,
          calendar: viewModel.calendar,
          onBack: onBack,
          onClose: onClose,
          onClearReturn: { viewModel.clearReturn() },
          startDateEmptyTitle: viewModel.departurePlaceholder,
          endDateEmptyTitle: viewModel.returnPlaceholder,
          isDismissEndEnabled: viewModel.isDismissEndEnabled,
          showPlusIconForReturn: viewModel.showPlusIconForReturn,
          showsReturn: viewModel.showsReturn,
          showsTitleBar: chrome.showsTitleBar,
          showsDateRow: chrome.showsDateRow)
      }

      ZStack(alignment: .bottom) {
        CalendarRangeSelector(
          viewModel: viewModel,
          proxy: proxy,
          bottomInset: chrome.showsFooter ? footerHeight : 0)

        if chrome.showsFooter {
          CalendarFooter(
            holidayCategories: viewModel.visibleHolidayCategories,
            locale: viewModel.locale,
            onClear: { viewModel.clear() },
            onApply: { onApply(viewModel.selectedRange) },
            clearEnabled: viewModel.clearEnabled,
            applyEnabled: viewModel.applyEnabled,
            showsLegend: viewModel.showsLegend,
            showsClearButton: chrome.showsClearButton,
            showsApplyButton: chrome.showsApplyButton)
          .onPreferenceChange(FooterHeightKey.self) { footerHeight = $0 }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(style.theme.surface.ignoresSafeArea())
    .environment(\.layoutDirection, viewModel.isRTL ? .rightToLeft : .leftToRight)
    .onAppear {
      //: jump to the anchored month without animation.
      let calendar = viewModel.calendar
      proxy.scrollToMonth(
        containing: viewModel.firstVisibleMonth.yearMonth.firstDayDate(in: calendar),
        scrollPosition: .firstFullyVisiblePosition,
        animated: false)
      // Wire the public controller's scroll(to:) to the HorizonCalendar proxy. Clamp the target
      // month into the visible range — HorizonCalendar fatalErrors if asked to scroll out of range.
      controller?.scrollHandler = { date, animated in
        let targetMonth = CalDate(date, in: calendar).calMonth
          .coerced(in: viewModel.startMonth.yearMonth, viewModel.endMonth.yearMonth)
        proxy.scrollToMonth(
          containing: targetMonth.firstDayDate(in: calendar),
          scrollPosition: .firstFullyVisiblePosition,
          animated: animated)
      }
    }
    .onDisappear { controller?.scrollHandler = nil }
  }
}
