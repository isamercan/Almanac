import SwiftUI
import Almanac

/// Hosts the reusable `CalendarStyleConfigurator` from Almanac (live preview + controls +
/// generated Swift you can copy/share).
struct ConfiguratorView: View {
  @State private var style = CalendarStyle.standard

  var body: some View {
    CalendarStyleConfigurator(style: $style)
      .navigationTitle("Konfigüratör")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack { ConfiguratorView() }
}
