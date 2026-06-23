import SwiftUI

public extension View {
  /// Presents the range picker full-screen while `isPresented` is true. The picker dismisses itself
  /// on Apply (→ `onApply`) and on back/close (→ `onCancel`).
  ///
  ///     .calendarRangePicker(isPresented: $show, configuration: cfg) { result in … }
  func calendarRangePicker(
    isPresented: Binding<Bool>,
    configuration: CalendarPickerConfiguration,
    onApply: @escaping (CalendarPickerResult) -> Void,
    onCancel: @escaping () -> Void = {}) -> some View
  {
    fullScreenCover(isPresented: isPresented) {
      CalendarRangePickerView(
        configuration: configuration,
        onApply: { result in isPresented.wrappedValue = false; onApply(result) },
        onCancel: { isPresented.wrappedValue = false; onCancel() })
    }
  }
}
