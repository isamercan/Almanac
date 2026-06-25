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
  @Environment(\.calendarContent) private var content
  @State private var proxy = CalendarViewProxy()
  @State private var footerHeight: CGFloat = 0
  @State private var accessoryHeight: CGFloat = 0

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
          bottomInset: bottomOverlayInset)

        if chrome.showsTodayButton {
          todayButton
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(.trailing, 16)
            .padding(.bottom, bottomOverlayInset + 16)
        }

        VStack(spacing: 0) {
          if let accessory = content.selectedDateAccessory, let date = selectedAccessoryDate {
            accessory(date)
              .frame(maxWidth: .infinity)
              .background(
                GeometryReader { inner in
                  Color.clear.preference(key: AccessoryHeightKey.self, value: inner.size.height)
                })
          }

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
        .onPreferenceChange(AccessoryHeightKey.self) { accessoryHeight = $0 }
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

  // MARK: - Bottom overlay (accessory + footer)

  /// Calendar bottom content inset = footer (when shown) + selected-date accessory (when present).
  private var bottomOverlayInset: CGFloat {
    (viewModel.chrome.showsFooter ? footerHeight : 0) + accessoryHeight
  }

  /// The day handed to the `.calendarSelectedDateAccessory` closure: the range end if set, else the
  /// start; nil when nothing is selected.
  private var selectedAccessoryDate: Date? {
    let range = viewModel.selectedRange
    let calendar = viewModel.calendar
    if let end = range.end { return end.startOfDay(in: calendar) }
    if let start = range.start { return start.startOfDay(in: calendar) }
    return nil
  }

  // MARK: - Today button (opt-in via `chrome.showsTodayButton`)

  private var todayButton: some View {
    Button(action: scrollToToday) {
      Label(
        L10n.string(L10n.Key.today, locale: viewModel.locale),
        systemImage: "calendar.circle")
        .calendarTextStyle(style.typography.button)
        .foregroundStyle(style.theme.onInk)
        .padding(.horizontal, 16)
        .frame(height: 40)
        .background(style.theme.ink, in: Capsule())
        .shadow(color: .black.opacity(0.18), radius: 8, y: 2)
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("calendar.today")
    .accessibilityLabel(L10n.string(L10n.Key.today, locale: viewModel.locale))
  }

  /// Scrolls the grid to the month containing today, clamped into the visible range.
  private func scrollToToday() {
    let calendar = viewModel.calendar
    let target = viewModel.today.date.calMonth
      .coerced(in: viewModel.startMonth.yearMonth, viewModel.endMonth.yearMonth)
    proxy.scrollToMonth(
      containing: target.firstDayDate(in: calendar),
      scrollPosition: .firstFullyVisiblePosition,
      animated: true)
  }
}
