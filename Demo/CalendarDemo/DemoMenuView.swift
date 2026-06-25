import SwiftUI
import Almanac

/// Demo home: configure language / return-lock, present the range picker and the hotel picker
/// (both full-screen, like an Activity), and open the standalone TimeWheel page.
struct DemoMenuView: View {
  @State private var showRange = false
  @State private var showHotel = false
  @State private var showWheel = false
  @State private var showCustom = false
  @State private var showStyled = false
  @State private var showYear = false
  @State private var showConfigurator = false
  @State private var showBare = false
  @State private var showChromeDemo = false
  @State private var showHijri = false

  /// A heavily-restyled CalendarStyle — proves the full design is configurable from one object.
  private var customStyle: CalendarStyle {
    var s = CalendarStyle.standard
    s.theme.ink = .indigo
    s.theme.inBetweenFill = Color.indigo.opacity(0.15)
    s.metrics.daySelectionShape = .roundedRectangle(cornerRadius: 10)
    s.metrics.footerCornerRadius = 12
    s.metrics.buttonHeight = 56
    s.metrics.todayRingWidth = 3
    s.metrics.holidayDotSize = 6
    s.typography.dayNumber.size = 18
    s.typography.dayNumber.weight = .bold
    s.typography.button.weight = .heavy
    return s
  }
  @State private var localeTag = "tr"
  @State private var isReturn = false
  @State private var singleDate = false
  @State private var showPrices = false
  @State private var horizontal = false
  @State private var sundayStart = false
  @State private var hideChrome = false
  @State private var showTodayButton = false
  @State private var resultText: String?
  /// Deep-links straight to a gallery example (for screenshots / headless verification).
  @State private var autoExample: CalendarExample?

  private var configuration: CalendarPickerConfiguration {
    CalendarPickerConfiguration(
      goingDate: singleDate ? DemoData.date(daysFromNow: 3) : DemoData.date(daysFromNow: 3),
      returnDate: singleDate ? nil : DemoData.date(daysFromNow: 9),
      isReturn: isReturn,
      maxSelectableDate: DemoData.date(daysFromNow: 300),
      holidays: DemoData.holidays(),
      localeTag: localeTag,
      restorationID: "demo.range",
      blockedDates: DemoData.blocked(),
      priceByDate: showPrices ? DemoData.prices() : [:],
      minNights: singleDate ? nil : 2,
      selectionMode: singleDate ? .single : .range,
      horizontalPaging: horizontal,
      calendar: demoCalendar,
      chrome: CalendarChrome(
        showsWeekdayHeader: !hideChrome, showsLegend: !hideChrome, showsTodayButton: showTodayButton))
  }

  private var demoCalendar: Calendar {
    var cal = Calendar(identifier: .gregorian)
    cal.firstWeekday = sundayStart ? 1 : 2
    cal.timeZone = .current
    return cal
  }

  var body: some View {
    NavigationStack {
      List {
        if let resultText {
          Section("Son sonuç") {
            Text(resultText).font(.footnote).foregroundStyle(.secondary)
              .accessibilityIdentifier("menu.result")
          }
        }

        Section("Dil / Mod") {
          Picker("Dil", selection: $localeTag) {
            Text("Türkçe").tag("tr")
            Text("English").tag("en")
            Text("العربية").tag("ar")
          }
          .pickerStyle(.segmented)
          Toggle("isReturn (dönüş kilidi)", isOn: $isReturn)
          Toggle("Tek tarih modu", isOn: $singleDate)
          Toggle("Fiyat rozetleri", isOn: $showPrices)
          Toggle("Yatay sayfalama", isOn: $horizontal)
          Toggle("Pazar başlangıç", isOn: $sundayStart)
          Toggle("Başlık/legend gizle", isOn: $hideChrome)
          Toggle("Bugün butonu", isOn: $showTodayButton)
        }

        Section("Takvim") {
          Button("Aralık Seçici (Uçuş / Otobüs)") { showRange = true }
            .accessibilityIdentifier("menu.range")
          Button("Otel Takvimi") { showHotel = true }
            .accessibilityIdentifier("menu.hotel")
          Button("Özel Gün Stili (calendarDay)") { showCustom = true }
            .accessibilityIdentifier("menu.custom")
          Button("Özel Tasarım (calendarStyle)") { showStyled = true }
            .accessibilityIdentifier("menu.styled")
        }

        Section("Calendar Library Örnekleri") {
          NavigationLink("Tüm Örnekler (13)") { ExamplesListView() }
            .accessibilityIdentifier("menu.examples")
        }

        Section("Görünüm") {
          NavigationLink("Browse (Yıl ↔ Ay) + Tema + Accessory") {
            BrowseDemoView(configuration: configuration)
          }
          .accessibilityIdentifier("menu.browse")
          NavigationLink("Hafta Takvimi (CalendarWeekView)") {
            WeekCalendarDemoView(configuration: configuration)
          }
          .accessibilityIdentifier("menu.week")
          NavigationLink("Yıl Görünümü (2026)") {
            YearOverviewDemoView(configuration: configuration)
          }
          NavigationLink("Tasarım Konfigüratörü") {
            ConfiguratorView()
          }
          NavigationLink("Sadece Takvim (chrome yok)") {
            BareCalendarDemoView(configuration: configuration)
          }
        }

        Section("Saat") {
          NavigationLink("Saat Tekerleği (TimeWheel)") { TimeWheelDemoView() }
          NavigationLink("Tarih + Saat") { DateTimeDemoView() }
        }
      }
      .navigationTitle("Almanac Demo")
    }
    .onAppear {
      // Lets the demo be driven headlessly for screenshots (SIMCTL_CHILD_DEMO_AUTOPRESENT=…).
      let env = ProcessInfo.processInfo.environment
      if let loc = env["DEMO_LOCALE"] { localeTag = loc }
      if env["DEMO_PRICES"] == "1" { showPrices = true }
      if env["DEMO_SINGLE"] == "1" { singleDate = true }
      if env["DEMO_HORIZONTAL"] == "1" { horizontal = true }
      if env["DEMO_SUNDAY"] == "1" { sundayStart = true }
      if env["DEMO_NOCHROME"] == "1" { hideChrome = true }
      if let n = env["DEMO_EXAMPLE"], let i = Int(n), let ex = CalendarExample(rawValue: i) {
        autoExample = ex
      }
      switch env["DEMO_AUTOPRESENT"] {
      case "range": showRange = true
      case "hotel": showHotel = true
      case "wheel": showWheel = true
      case "custom": showCustom = true
      case "styled": showStyled = true
      case "year": showYear = true
      case "configurator": showConfigurator = true
      case "bare": showBare = true
      case "chrome": showChromeDemo = true
      case "hijri": showHijri = true
      default: break
      }
    }
    .fullScreenCover(item: $autoExample) { example in
      NavigationStack {
        example.destination
          .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Kapat") { autoExample = nil } } }
      }
    }
    .fullScreenCover(isPresented: $showHijri) {
      // Non-Gregorian calendar: Islamic (Umm al-Qura), Arabic locale, Saturday-first.
      var hijri = Calendar(identifier: .islamicUmmAlQura)
      hijri.firstWeekday = 7
      hijri.timeZone = .current
      let cfg = CalendarPickerConfiguration(
        goingDate: DemoData.date(daysFromNow: 3),
        returnDate: DemoData.date(daysFromNow: 9),
        localeTag: "ar",
        calendar: hijri)
      return CalendarRangePickerView.rangeSelector(
        configuration: cfg,
        onApply: { _ in showHijri = false },
        onCancel: { showHijri = false })
    }
    .fullScreenCover(isPresented: $showChromeDemo) {
      // Partial chrome: no title bar, no legend, footer with only the Apply button.
      var cfg = configuration
      cfg.chrome = CalendarChrome(
        showsTitleBar: false, showsDateRow: true, showsWeekdayHeader: true,
        showsLegend: false, showsFooter: true, showsClearButton: false, showsApplyButton: true)
      return CalendarRangePickerView.rangeSelector(
        configuration: cfg,
        onApply: { _ in showChromeDemo = false },
        onCancel: { showChromeDemo = false })
    }
    .fullScreenCover(isPresented: $showBare) {
      NavigationStack {
        BareCalendarDemoView(configuration: configuration)
          .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Kapat") { showBare = false } } }
      }
    }
    .fullScreenCover(isPresented: $showConfigurator) {
      NavigationStack {
        ConfiguratorView()
          .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Kapat") { showConfigurator = false } } }
      }
    }
    .fullScreenCover(isPresented: $showStyled) {
      // Demonstrates the comprehensive design config: one CalendarStyle restyles everything.
      CalendarRangePickerView.rangeSelector(
        configuration: configuration,
        onApply: { result in resultText = format(result); showStyled = false },
        onCancel: { resultText = "İptal edildi"; showStyled = false })
      .calendarStyle(customStyle)
    }
    .fullScreenCover(isPresented: $showYear) {
      NavigationStack {
        CalendarYearView(year: 2026, locale: Locale(identifier: localeTag)) { _ in }
          .navigationTitle("2026")
          .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Kapat") { showYear = false } } }
      }
    }
    .fullScreenCover(isPresented: $showCustom) {
      // Demonstrates the composition API: a fully custom day cell via `.calendarDay`.
      CalendarRangePickerView.rangeSelector(
        configuration: configuration,
        onApply: { result in resultText = format(result); showCustom = false },
        onCancel: { resultText = "İptal edildi"; showCustom = false })
      .calendarDay { ctx in CustomDayCell(context: ctx) }
    }
    .fullScreenCover(isPresented: $showWheel) {
      NavigationStack {
        TimeWheelDemoView()
          .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Kapat") { showWheel = false } } }
      }
    }
    // Uses the public sheet modifier (handles its own dismissal).
    .calendarRangePicker(
      isPresented: $showRange,
      configuration: configuration,
      onApply: { result in resultText = format(result) },
      onCancel: { resultText = "İptal edildi" })
    .fullScreenCover(isPresented: $showHotel) {
      CalendarRangePickerView.hotel(
        configuration: configuration,
        onApply: { result in resultText = format(result); showHotel = false },
        onCancel: { resultText = "İptal edildi"; showHotel = false })
    }
  }

  private func format(_ result: CalendarPickerResult) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.locale = Locale(identifier: localeTag)
    let going = result.goingDate.map(formatter.string(from:)) ?? "—"
    let ret = result.returnDate.map(formatter.string(from:)) ?? "—"
    return "Gidiş: \(going)   •   Dönüş: \(ret)"
  }
}

/// A fully custom day cell built only from the public `CalendarDayContext` — proof that hosts can
/// completely restyle days without touching Almanac internals.
private struct CustomDayCell: View {
  let context: CalendarDayContext

  private var background: Color {
    if context.isSelected { return .purple }
    if context.isInBetween { return .purple.opacity(0.18) }
    return .clear
  }

  var body: some View {
    VStack(spacing: 2) {
      Text("\(context.day)")
        .font(.system(size: 15, weight: context.isSelected ? .bold : .regular))
        .foregroundStyle(context.isSelected ? .white : (context.isDisabled ? .secondary : .primary))
      if context.holidayColor != nil {
        Image(systemName: "star.fill").font(.system(size: 7)).foregroundStyle(.orange)
      }
    }
    .frame(maxWidth: .infinity, minHeight: 40)
    .background(background, in: RoundedRectangle(cornerRadius: 8))
    .opacity(context.isDisabled ? 0.4 : 1)
  }
}

#Preview {
  DemoMenuView()
}
