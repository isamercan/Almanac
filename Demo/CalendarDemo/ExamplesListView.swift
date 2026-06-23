import SwiftUI

/// The "Calendar Library" example gallery — a SwiftUI re-creation of the kizitonwose Calendar
/// sample app (calendar.kizitonwose.dev), with each screen rebuilt on Almanac's public API.
struct ExamplesListView: View {
  var body: some View {
    List {
      ForEach(CalendarExample.allCases) { example in
        NavigationLink {
          example.destination
        } label: {
          VStack(alignment: .leading, spacing: 4) {
            Text(example.title).font(.headline)
            Text(example.subtitle).font(.subheadline).foregroundStyle(.secondary)
          }
          .padding(.vertical, 4)
        }
        .accessibilityIdentifier("example.\(example.rawValue)")
      }
    }
    .navigationTitle("Calendar Library")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// The 11 examples, titled and described to mirror the original sample app's index.
enum CalendarExample: Int, CaseIterable, Identifiable {
  case e1 = 1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11
  // Variants present in the sample source but not as separate menu entries.
  case e2highlight = 12
  case e9animated = 13

  var id: Int { rawValue }

  var title: String {
    switch self {
    case .e2highlight: "Example 2 · Highlight"
    case .e9animated: "Example 9 · Animated"
    default: "Example \(rawValue)"
    }
  }

  var subtitle: String {
    switch self {
    case .e1: "Yatay takvim — ay başlığı, sayfalı kaydırma, programatik kaydırma."
    case .e2: "Dikey takvim — sabit başlık, aylar arası sürekli aralık seçimi, geçmiş günler devre dışı. Airbnb tarzı."
    case .e3: "Yatay takvim — tek tarih seçimi, fiyat rozetli uçuş takvimi."
    case .e4: "Yatay takvim — özel gün boyutu, özel ay başlığı ve özel hücre arka planları."
    case .e5: "Hafta takvimi — tek tarih seçimi, sayfalı kaydırma."
    case .e6: "Isı haritası takvimi — dinamik ay başlığı, sürekli kaydırma. GitHub katkı grafiği tarzı."
    case .e7: "Hafta takvimi — sürekli kaydırma, özel gün genişliği, tek tarih seçimi."
    case .e8: "Tam ekran yatay takvim — ay başlığı ve altbilgi, sayfalı yatay kaydırma."
    case .e9: "Animasyonlu ay ↔ hafta takvimi geçişi."
    case .e10: "Yatay yıl takvimi — sayfalı kaydırma. Büyük ekranlar için uygundur."
    case .e11: "Dikey yıl takvimi — sürekli kaydırma. Büyük ekranlar için uygundur."
    case .e2highlight: "Example 2 varyantı — modern Airbnb 'highlight' sürekli aralık stili."
    case .e9animated: "Example 9 varyantı — AnimatedVisibility ile ay ↔ hafta geçişi."
    }
  }

  @ViewBuilder var destination: some View {
    switch self {
    case .e1: Example1View()
    case .e2: Example2View()
    case .e3: Example3View()
    case .e4: Example4View()
    case .e5: Example5View()
    case .e6: Example6View()
    case .e7: Example7View()
    case .e8: Example8View()
    case .e9: Example9View()
    case .e10: Example10View()
    case .e11: Example11View()
    case .e2highlight: Example2HighlightView()
    case .e9animated: Example9AnimatedView()
    }
  }
}

#Preview {
  NavigationStack { ExamplesListView() }
}
