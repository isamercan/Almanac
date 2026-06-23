import SwiftUI

/// Public entry point for the range picker.
/// Configure it with `CalendarPickerConfiguration` and receive the applied range via `onApply`;
/// back and close both invoke `onCancel`.
public struct CalendarRangePickerView: View {
  @State private var viewModel: CalendarScreenViewModel
  /// In-progress selection persisted for state restoration (opt-in via `restorationID`).
  @SceneStorage private var storedRange: String
  private let persists: Bool
  private let controller: CalendarController?
  private let onApply: (CalendarPickerResult) -> Void
  private let onCancel: () -> Void
  /// Fires on every selection change (not just Apply), for live previews / streaming.
  private let onSelectionChange: ((CalendarPickerResult) -> Void)?

  public init(
    configuration: CalendarPickerConfiguration,
    controller: CalendarController? = nil,
    onApply: @escaping (CalendarPickerResult) -> Void,
    onCancel: @escaping () -> Void = {},
    onSelectionChange: ((CalendarPickerResult) -> Void)? = nil)
  {
    _viewModel = State(initialValue: configuration.makeViewModel())
    self.persists = configuration.restorationID != nil
    _storedRange = SceneStorage(
      wrappedValue: "",
      configuration.restorationID ?? "etscalendar.range.persistence.disabled")
    self.controller = controller
    self.onApply = onApply
    self.onCancel = onCancel
    self.onSelectionChange = onSelectionChange
  }

  public var body: some View {
    CalendarScreen(
      viewModel: viewModel,
      controller: controller,
      onBack: onCancel,
      onClose: onCancel,
      onApply: { range in onApply(CalendarPickerResult(range: range)) })
    .onAppear {
      // Restore a persisted in-progress selection (process death) before the user interacts.
      if persists, !storedRange.isEmpty, let restored = SelectedRange(sceneEncoded: storedRange) {
        viewModel.restore(restored)
      }
    }
    .onChange(of: viewModel.selectedRange) { _, newValue in
      if persists { storedRange = newValue.sceneEncoded }
      onSelectionChange?(CalendarPickerResult(range: newValue))
    }
  }
}

// MARK: - Factories (common presets)

public extension CalendarRangePickerView {
  /// Standard range picker (e.g. flights / buses).
  static func rangeSelector(
    configuration: CalendarPickerConfiguration,
    onApply: @escaping (CalendarPickerResult) -> Void,
    onCancel: @escaping () -> Void = {}) -> CalendarRangePickerView
  {
    CalendarRangePickerView(configuration: configuration, onApply: onApply, onCancel: onCancel)
  }

  /// Hotel variant, with check-in / check-out top-bar titles applied
  /// (only when the caller hasn't already set custom placeholders).
  static func hotel(
    configuration: CalendarPickerConfiguration,
    onApply: @escaping (CalendarPickerResult) -> Void,
    onCancel: @escaping () -> Void = {}) -> CalendarRangePickerView
  {
    var config = configuration
    config.departurePlaceholder = config.departurePlaceholder
      ?? L10n.string(L10n.Key.hotelCheckin, locale: config.locale)
    config.returnPlaceholder = config.returnPlaceholder
      ?? L10n.string(L10n.Key.hotelCheckout, locale: config.locale)
    return CalendarRangePickerView(configuration: config, onApply: onApply, onCancel: onCancel)
  }

  /// Rent-a-car variant, with pick-up / drop-off top-bar titles.
  static func rentACar(
    configuration: CalendarPickerConfiguration,
    onApply: @escaping (CalendarPickerResult) -> Void,
    onCancel: @escaping () -> Void = {}) -> CalendarRangePickerView
  {
    var config = configuration
    config.departurePlaceholder = config.departurePlaceholder
      ?? L10n.string(L10n.Key.rentacarPickup, locale: config.locale)
    config.returnPlaceholder = config.returnPlaceholder
      ?? L10n.string(L10n.Key.rentacarDropOff, locale: config.locale)
    return CalendarRangePickerView(configuration: config, onApply: onApply, onCancel: onCancel)
  }

  /// Builds the picker plus an `AsyncStream` of live selection changes. The stream finishes when
  /// the picker is applied or cancelled.
  ///
  ///     let (picker, changes) = CalendarRangePickerView.streamingSelection(configuration: cfg) { … } onCancel: { … }
  ///     for await result in changes { /* live updates */ }
  static func streamingSelection(
    configuration: CalendarPickerConfiguration,
    onApply: @escaping (CalendarPickerResult) -> Void,
    onCancel: @escaping () -> Void = {}) -> (view: CalendarRangePickerView, changes: AsyncStream<CalendarPickerResult>)
  {
    var continuation: AsyncStream<CalendarPickerResult>.Continuation!
    let stream = AsyncStream<CalendarPickerResult> { continuation = $0 }
    let view = CalendarRangePickerView(
      configuration: configuration,
      onApply: { result in continuation.finish(); onApply(result) },
      onCancel: { continuation.finish(); onCancel() },
      onSelectionChange: { continuation.yield($0) })
    return (view, stream)
  }
}
