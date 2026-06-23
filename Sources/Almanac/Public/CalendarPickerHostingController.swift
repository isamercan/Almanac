import SwiftUI
#if canImport(UIKit)
import UIKit

/// UIKit bridge — present the picker from UIKit code. Returns a
/// `UIHostingController` wrapping `CalendarRangePickerView`. The caller is responsible for
/// presenting/dismissing (e.g. in the `onApply` / `onCancel` callbacks).
public enum CalendarPickerHosting {
  @MainActor
  public static func makeViewController(
    configuration: CalendarPickerConfiguration,
    onApply: @escaping (CalendarPickerResult) -> Void,
    onCancel: @escaping () -> Void = {}) -> UIViewController
  {
    let view = CalendarRangePickerView(
      configuration: configuration,
      onApply: onApply,
      onCancel: onCancel)
    let controller = UIHostingController(rootView: view)
    controller.modalPresentationStyle = .fullScreen
    return controller
  }

  /// Presents the picker from [presenter] and awaits the result — `nil` when cancelled.
  /// `onSelectionChange` (optional) reports live changes before the user applies.
  ///
  ///     let result = await CalendarPickerHosting.present(configuration: cfg, from: self)
  @MainActor
  @discardableResult
  static func present(
    configuration: CalendarPickerConfiguration,
    from presenter: UIViewController,
    onSelectionChange: ((CalendarPickerResult) -> Void)? = nil) async -> CalendarPickerResult?
  {
    await withCheckedContinuation { continuation in
      var didResume = false
      func finish(_ result: CalendarPickerResult?) {
        guard !didResume else { return }
        didResume = true
        presenter.dismiss(animated: true)
        continuation.resume(returning: result)
      }
      let view = CalendarRangePickerView(
        configuration: configuration,
        onApply: { finish($0) },
        onCancel: { finish(nil) },
        onSelectionChange: onSelectionChange)
      let controller = UIHostingController(rootView: view)
      controller.modalPresentationStyle = .fullScreen
      presenter.present(controller, animated: true)
    }
  }
}
#endif
