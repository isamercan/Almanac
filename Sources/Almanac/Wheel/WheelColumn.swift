import SwiftUI
import Foundation

/// One scrollable drum column. Uses an iOS 17 snapping
/// `ScrollView` (`.viewAligned` + symmetric content margins) so the snapped item sits centered, and
/// provides a cylinder transform, continuous tick haptics, settle callback, and
/// soft-bound re-alignment.
struct WheelColumn: View {
  let items: [String]
  /// Externally-driven selected index (may be coerced by the parent's soft bounds).
  let selectedIndex: Int
  let onSelectedChanged: (Int) -> Void
  var textAlignment: Alignment = .center
  var textPadding: EdgeInsets = EdgeInsets()
  var config = TimePickerConfig()
  var isIndexDisabled: (Int) -> Bool = { _ in false }
  /// VoiceOver label for the whole column (e.g. "Hour").
  var accessibilityLabel: String = ""

  @State private var scrollID: Int?
  @State private var settleTask: Task<Void, Never>?

  private let spaceName = "wheelColumn"

  var body: some View {
    let viewportCenter = config.wheelHeight / 2

    ScrollView(.vertical, showsIndicators: false) {
      LazyVStack(spacing: 0) {
        ForEach(items.indices, id: \.self) { index in
          row(index: index, viewportCenter: viewportCenter)
            .frame(height: config.itemHeight)
            .id(index)
        }
      }
      .scrollTargetLayout()
    }
    .coordinateSpace(name: spaceName)
    .scrollTargetBehavior(.viewAligned)
    .scrollPosition(id: $scrollID)
    .contentMargins(.vertical, CGFloat(config.halfVisible) * config.itemHeight, for: .scrollContent)
    .frame(height: config.wheelHeight)
    .onAppear { if scrollID == nil { scrollID = selectedIndex } }
    .onChange(of: selectedIndex) { _, newValue in
      // The parent accepted/coerced the value — re-align the wheel to it with a snappy spring, and
      // cancel any pending settle re-assertion (this change already supersedes it).
      settleTask?.cancel()
      if scrollID != newValue {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) { scrollID = newValue }
      }
    }
    .onChange(of: scrollID) { _, newValue in
      guard let idx = newValue else { return }
      Haptics.wheelTick()       // tick on every center crossing, including while scrolling
      scheduleSettle(idx)
    }
    // VoiceOver: expose the column as a single adjustable element instead of a scroll of labels.
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(accessibilityLabel)
    .accessibilityValue(items.indices.contains(selectedIndex) ? items[selectedIndex] : "")
    .accessibilityAdjustableAction { direction in
      let next: Int
      switch direction {
      case .increment: next = min(selectedIndex + 1, items.count - 1)
      case .decrement: next = max(selectedIndex - 1, 0)
      @unknown default: return
      }
      if next != selectedIndex { onSelectedChanged(next) }
    }
  }

  /// Fires `onSelectedChanged` once the wheel stops moving on a new index (settle), mirroring the
  /// scroll view's in-progress true→false handling.
  private func scheduleSettle(_ idx: Int) {
    settleTask?.cancel()
    settleTask = Task { @MainActor in
      try? await Task.sleep(nanoseconds: 90_000_000)   // brief debounce so a settle isn't a mid-scroll crossing
      guard !Task.isCancelled else { return }
      if idx != selectedIndex { onSelectedChanged(idx) }

      // Re-assert alignment: if the parent coerced the value back to a boundary WITHOUT changing
      // `selectedIndex` (e.g. scrolling below the min while already at the min), `onChange` never
      // fires, so the wheel would rest on an out-of-bounds value. Snap it to the nearest valid one.
      // When the value *was* accepted/changed, `onChange(selectedIndex)` cancels this task first.
      try? await Task.sleep(nanoseconds: 70_000_000)
      guard !Task.isCancelled else { return }
      if scrollID != selectedIndex {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) { scrollID = selectedIndex }
      }
    }
  }

  @ViewBuilder
  private func row(index: Int, viewportCenter: CGFloat) -> some View {
    GeometryReader { geo in
      let mid = geo.frame(in: .named(spaceName)).midY
      let pixelOffset = mid - viewportCenter
      let radiusPx = config.cylinderRadius * config.itemHeight
      let halfPi = CGFloat.pi / 2
      let angle = max(-halfPi, min(halfPi, pixelOffset / radiusPx))
      let cosAngle = cos(angle)
      let alpha = pow(max(0, min(1, 1 - abs(angle) / halfPi)), config.fadingPower)
      let translationY = radiusPx * sin(angle) - pixelOffset

      Text(items[index])
        .font(config.font)
        .foregroundStyle(config.textColor.opacity(isIndexDisabled(index) ? 0.2 : 1))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: textAlignment)
        .padding(textPadding)
        .scaleEffect(x: 1, y: max(0.0001, cosAngle), anchor: .center)
        .rotation3DEffect(.radians(Double(angle)), axis: (x: 1, y: 0, z: 0), perspective: 0.2)
        .offset(y: translationY)
        .opacity(Double(alpha))
    }
  }
}
