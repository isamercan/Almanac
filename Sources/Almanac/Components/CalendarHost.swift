import SwiftUI
import UIKit
import HorizonCalendar

/// Scrolls the hosted month grid to a month.
///
/// Almanac drives HorizonCalendar's UIKit `CalendarView` directly (through `CalendarHost`), not its
/// SwiftUI `CalendarViewRepresentable`/`CalendarViewProxy`, which only exist from HorizonCalendar 2.0.
/// The UIKit API is the same in 1.16 and 2.x, so an app that pins HorizonCalendar 1.x can still use
/// Almanac. A scroll asked for before the grid exists is kept and run once it does.
@MainActor
final class CalendarScrollProxy: ObservableObject {
  private weak var calendarView: CalendarView?
  private var pending: (date: Date, animated: Bool)?

  /// Brings the month containing `date` to the top (vertical) or leading edge (horizontal).
  func scrollToMonth(containing date: Date, animated: Bool) {
    guard let calendarView else {
      pending = (date, animated)
      return
    }
    calendarView.scroll(
      toMonthContaining: date,
      scrollPosition: .firstFullyVisiblePosition(padding: 0),
      animated: animated)
  }

  fileprivate func attach(_ view: CalendarView) {
    calendarView = view
    if let pending {
      self.pending = nil
      scrollToMonth(containing: pending.date, animated: pending.animated)
    }
  }
}

/// HorizonCalendar's UIKit `CalendarView` in SwiftUI. The content (layout, item providers, spacing)
/// is rebuilt by the caller on every update and handed to `setContent(_:)`.
struct CalendarHost: UIViewRepresentable {
  let content: CalendarViewContent
  let backgroundColor: UIColor
  let layoutMargins: NSDirectionalEdgeInsets
  let proxy: CalendarScrollProxy
  /// A day was tapped: its year, month and day.
  let onDaySelection: (_ year: Int, _ month: Int, _ day: Int) -> Void
  /// The visible months changed: the first and last visible months.
  let onScroll: (_ first: CalMonth, _ last: CalMonth) -> Void

  func makeUIView(context: Context) -> CalendarView {
    let view = CalendarView(initialContent: content)
    configure(view)
    proxy.attach(view)
    return view
  }

  func updateUIView(_ view: CalendarView, context: Context) {
    view.setContent(content)
    configure(view)
  }

  private func configure(_ view: CalendarView) {
    view.backgroundColor = backgroundColor
    view.directionalLayoutMargins = layoutMargins
    let onDaySelection = onDaySelection
    view.daySelectionHandler = { day in
      onDaySelection(day.month.year, day.month.month, day.day)
    }
    let onScroll = onScroll
    view.didScroll = { visibleDayRange, _ in
      let first = visibleDayRange.lowerBound.month
      let last = visibleDayRange.upperBound.month
      onScroll(CalMonth(year: first.year, month: first.month), CalMonth(year: last.year, month: last.month))
    }
  }
}
