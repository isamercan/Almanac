# Roadmap

Directional, not a promise — order and scope may change. Ideas and PRs welcome (open an issue or a
discussion first for anything large).

## 0.1.x — polish
- [ ] Deterministic snapshot tests on CI (currently skipped via the `CI` env; explore tolerance-based
      comparison or a pinned simulator/OS so they can run in the matrix).
- [ ] Broaden localization beyond tr / en / ar (community-contributed `.strings`).
- [ ] DocC: more article-level guides (theming, composition, calendars) beyond symbol docs.

## 0.2.0 — capabilities
- [ ] **Week calendar as a first-class layout** (today the demo's week screens are plain SwiftUI;
      promote a real `WeekCalendarView` into the library).
- [ ] **Multiple / arbitrary date selection** mode (beyond range / single).
- [ ] **macOS / Mac Catalyst** support (audit UIKit-only paths; gate haptics & hosting bridge).
- [ ] Month/week toggle helper in the library (the demo's Example 9 pattern, packaged).

## Later
- [ ] Full Swift 6 strict-concurrency adoption and a `Sendable` audit across the public surface.
- [ ] Optional continuous-range "highlight" rendering as a built-in `CalendarStyle` option.
- [ ] Visual regression / accessibility audit pass (VoiceOver rotor, larger Dynamic Type).

## Non-goals
- A general-purpose calendar engine — Almanac is a focused date-range picker built on
  [HorizonCalendar](https://github.com/airbnb/HorizonCalendar); it does not aim to replace it.
- Networking, persistence, or a DI framework in the library.
