import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A drop-in, reusable design playground: a live calendar preview on top, with controls that drive
/// the bound `CalendarStyle` (day shape + colors + typography + metrics), plus generated Swift you
/// can copy or share. Embed it anywhere; the host owns the resulting style via the binding.
///
///     @State private var style = CalendarStyle.standard
///     CalendarStyleConfigurator(style: $style)
public struct CalendarStyleConfigurator: View {
  @Binding public var style: CalendarStyle

  /// Preview-only layout options — not part of the exported `CalendarStyle`.
  @State private var firstWeekday = 2
  @State private var horizontalPaging = false
  @State private var singleDate = false
  @State private var chrome = CalendarChrome.full

  public init(style: Binding<CalendarStyle>) {
    self._style = style
  }

  private let weights: [(String, Font.Weight)] = [
    ("Regular", .regular), ("Medium", .medium), ("Semibold", .semibold),
    ("Bold", .bold), ("Heavy", .heavy),
  ]

  public var body: some View {
    VStack(spacing: 0) {
      CalendarRangePickerView.rangeSelector(
        configuration: previewConfig,
        onApply: { _ in },
        onCancel: {})
      .calendarStyle(style)
      .id(previewIdentity)
      .frame(maxWidth: .infinity)
      .frame(height: 430)
      .clipped()
      .overlay(alignment: .bottom) { Divider() }

      Form {
        dayCellSection
        colorSection
        typographySection
        metricsSection
        layoutSection
        codeSection
      }
    }
  }

  // MARK: Day cell

  @ViewBuilder private var dayCellSection: some View {
    Section("Gün hücresi") {
      Picker("Şekil", selection: shapeKind) {
        ForEach(ShapeKind.allCases, id: \.self) { Text($0.label).tag($0) }
      }
      if case .roundedRectangle = style.metrics.daySelectionShape {
        slider("Köşe yarıçapı", cornerRadius, 0...24)
      }
      slider("Min boyut", $style.metrics.dayCellMinSize, 24...48)
      slider("Max boyut", $style.metrics.dayCellMaxSize, 36...64)
      slider("Bugün halka kalınlığı", $style.metrics.todayRingWidth, 0...6)
      slider("Aynı gün halka kalınlığı", $style.metrics.sameDayRingWidth, 0...8)
      slider("Tatil nokta boyutu", $style.metrics.holidayDotSize, 2...12)
      slider("Tatil nokta alt boşluğu", $style.metrics.holidayDotBottomPadding, 0...16)
    }
  }

  // MARK: Colors

  @ViewBuilder private var colorSection: some View {
    Section("Renkler") {
      ColorPicker("Seçili gün / vurgu (ink)", selection: $style.theme.ink)
      ColorPicker("Seçili gün yazısı (onInk)", selection: $style.theme.onInk)
      ColorPicker("Seçili aralık", selection: $style.theme.inBetweenFill)
      ColorPicker("Bugün (aktif) rengi", selection: $style.theme.todayRing)
      ColorPicker("Tatil noktası", selection: $style.theme.holidayDot)
      ColorPicker("Zemin", selection: $style.theme.surface)
      ColorPicker("Çizgi / devre dışı", selection: $style.theme.line)
      ColorPicker("Hafta sonu yazısı", selection: $style.theme.weekendText)
      ColorPicker("Pasif buton zemini", selection: $style.theme.disabledButtonContainer)
      ColorPicker("Pasif buton yazısı", selection: $style.theme.disabledButtonContent)
    }
  }

  // MARK: Typography

  @ViewBuilder private var typographySection: some View {
    Section("Tipografi — boyut") {
      slider("Gün no", $style.typography.dayNumber.size, 11...28)
      slider("Ay başlığı", $style.typography.monthTitle.size, 10...22)
      slider("Hafta günü", $style.typography.weekdayLabel.size, 9...20)
      slider("Üst bar başlığı", $style.typography.topBarTitle.size, 13...26)
      slider("Tarih etiketi", $style.typography.dateLabel.size, 12...24)
      slider("Buton", $style.typography.button.size, 12...22)
      slider("Legend", $style.typography.legend.size, 9...20)
    }
    Section("Tipografi — ağırlık") {
      weightPicker("Gün no", $style.typography.dayNumber.weight)
      weightPicker("Ay başlığı", $style.typography.monthTitle.weight)
      weightPicker("Tarih etiketi", $style.typography.dateLabel.weight)
      weightPicker("Buton", $style.typography.button.weight)
    }
  }

  // MARK: Metrics

  @ViewBuilder private var metricsSection: some View {
    Section("Yerleşim") {
      slider("Hafta satır aralığı", $style.metrics.weekRowSpacing, 0...20)
      slider("Aylar arası boşluk", $style.metrics.interMonthSpacing, 0...40)
      slider("Yatay kenar boşluğu", $style.metrics.horizontalPadding, 0...24)
      slider("Ay başlığı üst boşluk", $style.metrics.monthHeaderTopPadding, 0...48)
      slider("Ay başlığı alt boşluk", $style.metrics.monthHeaderBottomPadding, 0...24)
    }
    Section("Üst bar") {
      slider("Yükseklik", $style.metrics.topBarHeight, 44...80)
      slider("Yatay boşluk", $style.metrics.topBarHorizontalPadding, 0...32)
      slider("Tarih satırı dikey boşluk", $style.metrics.dateRowVerticalPadding, 0...40)
      slider("Tarih çevirme süresi (sn)", durationBinding(\.dateFlipDuration), 0...1)
    }
    Section("Footer & butonlar") {
      slider("Footer köşe yarıçapı", $style.metrics.footerCornerRadius, 0...40)
      slider("Footer gölgesi", $style.metrics.footerShadowRadius, 0...30)
      slider("Footer yatay boşluk", $style.metrics.footerHorizontalPadding, 0...40)
      slider("Footer dikey boşluk", $style.metrics.footerVerticalPadding, 0...40)
      slider("Buton yüksekliği", $style.metrics.buttonHeight, 36...64)
      slider("Buton aralığı", $style.metrics.buttonSpacing, 0...24)
      slider("Buton kenarlık", $style.metrics.buttonBorderWidth, 0...4)
      slider("Legend nokta boyutu", $style.metrics.legendDotSize, 4...16)
    }
    Section("Animasyon") {
      slider("Seçim animasyonu (sn)", durationBinding(\.selectionAnimationDuration), 0...1)
    }
  }

  // MARK: Preview layout (not exported)

  @ViewBuilder private var layoutSection: some View {
    Section("Önizleme düzeni") {
      Picker("Hafta başlangıcı", selection: $firstWeekday) {
        Text("Pazartesi").tag(2); Text("Pazar").tag(1)
      }
      Toggle("Yatay sayfalama", isOn: $horizontalPaging)
      Toggle("Tek tarih modu", isOn: $singleDate)
    }
    Section("Chrome (göster/gizle)") {
      Toggle("Üst bar (başlık)", isOn: $chrome.showsTitleBar)
      Toggle("Tarih satırı", isOn: $chrome.showsDateRow)
      Toggle("Hafta günü başlığı", isOn: $chrome.showsWeekdayHeader)
      Toggle("Footer paneli", isOn: $chrome.showsFooter)
      Toggle("Legend", isOn: $chrome.showsLegend)
      Toggle("Temizle butonu", isOn: $chrome.showsClearButton)
      Toggle("Uygula butonu", isOn: $chrome.showsApplyButton)
    }
  }

  // MARK: Generated code

  @ViewBuilder private var codeSection: some View {
    Section("Swift kodu") {
      Text(style.generatedSwiftCode)
        .font(.system(.caption, design: .monospaced))
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, alignment: .leading)
      HStack {
        #if canImport(UIKit)
        Button {
          UIPasteboard.general.string = style.generatedSwiftCode
        } label: { Label("Kopyala", systemImage: "doc.on.doc") }
        .buttonStyle(.bordered)
        #endif
        ShareLink(item: style.generatedSwiftCode) { Label("Paylaş", systemImage: "square.and.arrow.up") }
          .buttonStyle(.bordered)
        Spacer()
        Button("Sıfırla", role: .destructive) { withAnimation { style = .standard } }
      }
    }
  }

  // MARK: Control helpers

  private enum ShapeKind: CaseIterable, Hashable {
    case circle, rounded, square
    var label: String {
      switch self { case .circle: "Daire"; case .rounded: "Yuvarlak"; case .square: "Kare" }
    }
  }

  private var shapeKind: Binding<ShapeKind> {
    Binding {
      switch style.metrics.daySelectionShape {
      case .circle: .circle
      case .roundedRectangle: .rounded
      case .square: .square
      }
    } set: { kind in
      switch kind {
      case .circle: style.metrics.daySelectionShape = .circle
      case .rounded: style.metrics.daySelectionShape = .roundedRectangle(cornerRadius: currentCornerRadius)
      case .square: style.metrics.daySelectionShape = .square
      }
    }
  }

  private var currentCornerRadius: CGFloat {
    if case .roundedRectangle(let radius) = style.metrics.daySelectionShape { return radius }
    return 10
  }

  private var cornerRadius: Binding<CGFloat> {
    Binding { currentCornerRadius } set: { style.metrics.daySelectionShape = .roundedRectangle(cornerRadius: $0) }
  }

  private func durationBinding(_ keyPath: WritableKeyPath<CalendarMetrics, Double>) -> Binding<CGFloat> {
    Binding(
      get: { CGFloat(style.metrics[keyPath: keyPath]) },
      set: { style.metrics[keyPath: keyPath] = Double($0) })
  }

  private func weightPicker(_ title: String, _ binding: Binding<Font.Weight>) -> some View {
    Picker(title, selection: binding) {
      ForEach(weights, id: \.1) { Text($0.0).tag($0.1) }
    }
  }

  private func slider(_ title: String, _ value: Binding<CGFloat>, _ range: ClosedRange<CGFloat>) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack {
        Text(title)
        Spacer()
        Text(String(format: "%g", Double(value.wrappedValue)))
          .foregroundStyle(.secondary).monospacedDigit()
      }
      .font(.subheadline)
      Slider(value: value, in: range)
    }
  }

  // MARK: Preview data

  private var previewConfig: CalendarPickerConfiguration {
    CalendarPickerConfiguration(
      goingDate: Self.offsetDate(3),
      returnDate: singleDate ? nil : Self.offsetDate(9),
      maxSelectableDate: Self.offsetDate(300),
      holidays: Self.sampleHolidays(),
      localeTag: "tr",
      minNights: singleDate ? nil : 2,
      selectionMode: singleDate ? .single : .range,
      horizontalPaging: horizontalPaging,
      calendar: previewCalendar,
      chrome: chrome)
  }

  private var previewCalendar: Calendar {
    var cal = Calendar(identifier: .gregorian)
    cal.firstWeekday = firstWeekday
    cal.timeZone = .current
    return cal
  }

  private var previewIdentity: String {
    "\(firstWeekday)-\(horizontalPaging)-\(singleDate)-\(chrome)"
  }

  private static func offsetDate(_ days: Int) -> Date {
    let cal = Calendar(identifier: .gregorian)
    return cal.date(byAdding: .day, value: days, to: cal.startOfDay(for: Date())) ?? Date()
  }

  private static func sampleHolidays() -> [HolidayEntry] {
    func entry(_ offsets: [Int], _ argb: UInt32, _ name: String) -> HolidayEntry {
      let cal = Calendar(identifier: .gregorian)
      let dates = offsets.map { off -> ETSCalendarDate in
        let date = cal.date(byAdding: .day, value: off, to: cal.startOfDay(for: Date())) ?? Date()
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return ETSCalendarDate(day: c.day ?? 1, month: c.month ?? 1, year: c.year ?? 2026)
      }
      return HolidayEntry(dates: dates, colorARGB: argb, description: name)
    }
    return [
      entry([5, 6], 0xFF008CFF, "Resmî Tatil"),
      entry([12, 13], 0xFFE53935, "Bayram"),
    ]
  }
}
