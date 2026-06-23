import SwiftUI
import Almanac

/// Standalone showcase of the drum time pickers (the source's `TimeWheel` is not wired into the
/// calendar, so it gets its own page here). Bounds match the source previews.
struct TimeWheelDemoView: View {
  @State private var hour24 = 14
  @State private var minute24 = 30

  @State private var hour12 = 8
  @State private var minute12 = 30
  @State private var isAm = true

  var body: some View {
    ScrollView {
      VStack(spacing: 40) {
        VStack(spacing: 12) {
          Text("24 saat").font(.headline)
          TimeWheel24(
            hour: hour24,
            minute: minute24,
            onTimeChanged: { h, m in hour24 = h; minute24 = m },
            minHour: 8, minMinute: 15, maxHour: 20, maxMinute: 0)
            .frame(maxWidth: .infinity)
          Text(String(format: "Seçilen: %02d:%02d", hour24, minute24))
            .font(.subheadline).foregroundStyle(.secondary)
        }

        Divider()

        VStack(spacing: 12) {
          Text("12 saat (AM/PM)").font(.headline)
          TimeWheelAmPm(
            hour: hour12,
            minute: minute12,
            isAm: isAm,
            onTimeChanged: { h, m, a in hour12 = h; minute12 = m; isAm = a },
            minHour: 8, minMinute: 15, maxHour: 23, maxMinute: 45)
            .frame(maxWidth: .infinity)
          Text(String(format: "Seçilen: %d:%02d %@", hour12, minute12, isAm ? "AM" : "PM"))
            .font(.subheadline).foregroundStyle(.secondary)
        }
      }
      .padding()
    }
    .navigationTitle("TimeWheel")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack { TimeWheelDemoView() }
}
