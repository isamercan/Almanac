import SwiftUI
import Almanac

/// Shows `CalendarGridView` — the bare calendar with **no built-in top bar / footer** — embedded in
/// the host's own layout (custom header + custom action button).
struct BareCalendarDemoView: View {
  let configuration: CalendarPickerConfiguration

  @State private var result: CalendarPickerResult?

  var body: some View {
    VStack(spacing: 0) {
      Text("Takvim chrome'suz; başlık ve buton host'a ait")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.vertical, 8)

      CalendarGridView(configuration: configuration) { result = $0 }

      VStack(spacing: 8) {
        Text(selectionText).font(.subheadline).monospacedDigit()
        Button("Devam Et") {}
          .buttonStyle(.borderedProminent)
          .disabled(result?.goingDate == nil)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(.thinMaterial)
    }
    .navigationTitle("Sadece Takvim")
    .navigationBarTitleDisplayMode(.inline)
  }

  private var selectionText: String {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.locale = Locale(identifier: "tr")
    let going = result?.goingDate.map(f.string(from:)) ?? "—"
    let ret = result?.returnDate.map(f.string(from:)) ?? "—"
    return "Gidiş: \(going)  •  Dönüş: \(ret)"
  }
}
