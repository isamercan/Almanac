import SwiftUI
import Almanac

/// A combined date + time flow: pick a day, then pick the time with `TimeWheel24`, and see the
/// resulting `Date`. Shows the standalone wheel integrated into a real date+time selection.
struct DateTimeDemoView: View {
  @State private var day = Calendar.current.startOfDay(for: Date())
  @State private var hour = 9
  @State private var minute = 30

  private var combined: Date {
    Calendar.current.date(
      bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
  }

  private var formatted: String {
    let f = DateFormatter()
    f.dateStyle = .full
    f.timeStyle = .short
    return f.string(from: combined)
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 28) {
        DatePicker("Gün", selection: $day, displayedComponents: .date)
          .datePickerStyle(.compact)

        VStack(spacing: 8) {
          Text("Saat").font(.headline)
          TimeWheel24(
            hour: hour,
            minute: minute,
            onTimeChanged: { h, m in hour = h; minute = m })
            .frame(maxWidth: .infinity)
        }

        VStack(spacing: 4) {
          Text("Seçilen tarih-saat").font(.caption).foregroundStyle(.secondary)
          Text(formatted).font(.headline).multilineTextAlignment(.center)
        }
        .padding(.top, 8)
      }
      .padding()
    }
    .navigationTitle("Tarih + Saat")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack { DateTimeDemoView() }
}
