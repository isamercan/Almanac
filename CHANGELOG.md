# Changelog

All notable changes to Almanac are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com); this project aims to follow [SemVer](https://semver.org).

## [Unreleased]

### Added
- **CalendarRangePickerView** — full date-range picker (top bar + grid + footer) with Apply/Cancel.
- **CalendarGridView** — bare scrolling month grid (no chrome) for embedding.
- **CalendarChrome** — independently toggle title bar, date row, weekday header, legend, footer,
  Clear / Apply buttons (`.full` / `.none` / custom).
- **CalendarStyle** — one config for the whole design: `theme` (colors), `typography`, `metrics`
  (sizes, spacings, radii, animation, line widths), plus `CalendarDayShape` (circle / rounded / square).
  Inject with `.calendarStyle(_:)`; `.calendarTheme(_:)` is a colors-only shortcut.
- **Composition** — `.calendarDay`, `.calendarMonthHeader`, `.calendarWeekdayHeader`, `.calendarLegend`
  overrides fed a public `CalendarDayContext`.
- **CalendarStyleConfigurator** — live design playground that generates copyable Swift
  (`CalendarStyle.generatedSwiftCode`).
- **Injectable `Calendar` + timeZone** — non-Gregorian calendars (e.g. Islamic) and fixed timezones.
- **Layout/navigation** — horizontal paging, configurable first weekday, `CalendarController`
  (`scroll(to:)`, `scrollToToday()`), `CalendarYearView` 12-month overview.
- **Travel features** — blocked dates, per-day price badges, min/max nights, single-date mode,
  hotel / rent-a-car titles, state restoration (`restorationID`), opt-out haptics.
- **TimeWheel24 / TimeWheelAmPm** — iOS-style drum time pickers with soft min/max snap-back.
- **Accessibility** — VoiceOver day labels, adjustable wheels, Dynamic Type, **Reduce Motion**.
- **i18n** — tr (default), en, ar (RTL).
- Image snapshot tests, XCUITests, unit tests, GitHub Actions CI, SwiftLint config, DocC catalog.

### Performance
- Cached the Gregorian `Calendar` and locale-keyed `DateFormatter`s (previously re-allocated per call).

### Notes
- Minimum iOS 17. Sole runtime dependency: Airbnb HorizonCalendar.
