# CLAUDE.md — Almanac

Guidance for working in **Almanac**, a self-contained SwiftUI date-range calendar package for iOS.

---

## What this is

A **reusable SwiftUI date-range calendar picker** component (plus a standalone iOS-style wheel time
picker). It is a UI component library, **not a full app**: no database, no networking, no DI
framework, no background work. The `CalendarDemo` target only exists to host and run the component.

Module name: `Almanac`. Public types that concern the cross-host input/output API use the `ETS`
prefix (e.g. `ETSCalendarDate`); internal SwiftUI components use plain `Calendar*` names.

---

## Repository layout

```
.
├── Package.swift            # the library (repo-root Swift package)
├── Sources/Almanac/         # Public · Screen · Components · Wheel · Model · Theme · Common · Resources
├── Tests/AlmanacTests/      # unit + snapshot tests
└── Demo/                    # runnable example app + UI tests
    └── calendar-ios.xcodeproj
```

---

## Core behaviour (locked by tests)

The following rules are the heart of the component and are covered by `Tests/AlmanacTests`. Change
them only with an accompanying test:

- The day-tap selection state machine (`firstTap`, `lockStart`, partial-close, restart).
- Selectable/disabled rules (`< today`, `< minDate`, `> maxDate`; `minDate = lockStart ? start : nil`).
- Month bounds (`startMonth`, `endMonth` from `maxSelectableDate`, `firstVisibleMonth` clamping).
- Result mapping (`start == nil` ⇒ `end` forced `nil`).
- Holiday dot/legend derivation (last-entry-wins per date; per-month `distinctBy description`;
  visible-months-only legend; `legendKey = description#color`; `sortKey = yyyymmdd`).
- Wheel physics + soft min/max snap-back + 12↔24 hour conversion.

---

## Tech stack

| Concern | Choice |
|---|---|
| UI | SwiftUI (iOS 17+) |
| State / logic | MVVM with `@Observable` view models; state hoisted to the screen |
| Async/reactivity | `async/await`, `AsyncStream`, Combine where it fits |
| Persistence | **None.** State survival via `@State` + `@SceneStorage` (epoch-day encoding) |
| Dates | `CalDate`/`CalMonth` value types over an injectable `Calendar` (TZ-stable); bridged to `Date`/`DayComponents` at the HorizonCalendar boundary |
| Calendar grid | **Airbnb HorizonCalendar** (SPM, v2.0.0) — `CalendarViewRepresentable` |
| Icons | SF Symbols |
| Haptics | `UIImpactFeedbackGenerator` (day tap), `UISelectionFeedbackGenerator` (wheel tick) |
| Localization | `.strings` (tr/en/ar) + `Locale`-driven `DateFormatter`; BCP-47 override supported |
| Dependency mgmt | SPM. Only runtime dependency: `airbnb/HorizonCalendar` |

HorizonCalendar provides only the scrolling month-grid engine. **All day-cell visuals and selection
logic stay ours**: render `CalendarDayIndicator` inside `.days { }`, drive taps through
`.onDaySelection { }` into the view model's state machine. Do **not** use HorizonCalendar's
`dayRanges` (continuous bar) — the in-between look is rendered per-cell.

Do **not** introduce SwiftData/Core Data, URLSession networking, a DI container, or BackgroundTasks
— the component has no need for them.

---

## Conventions

- **One component per file**, named `Calendar<Thing>.swift` / `TimeWheel*.swift`.
- **Value semantics & immutability**: prefer `struct`, `let`, value types. Swift arrays/dicts are
  already value types — no immutable-collections dependency needed.
- **State hoisting**: the screen view model owns `SelectedRange`; child views take inputs + closures
  and stay previewable/host-agnostic (every input pre-resolved by the caller).
- **Design tokens**: colors in `CalendarColors`, text styles in `CalendarTypography`, sizes/radii in
  `CalendarMetrics`. Components read `@Environment(\.calendarStyle)`.
- **Localization keys** use the `etscalendar_*` names (`etscalendar_clear`, `etscalendar_action_apply`,
  `etscalendar_select_date_prompt`, `etscalendar_departure_date`, `etscalendar_add_return`,
  `etscalendar_hotel_*`, `etscalendar_rentacar_*`, …). tr is the default; en/ar are alternates.
- **Fonts**: text uses the **system font** (San Francisco) at fixed design sizes with
  Light/Medium/SemiBold weights. No bundled fonts.
- **SwiftUI Previews**: provide tr/en and the flight/hotel/car variants for the top bar, plus
  day-cell and footer states.
- **Docs**: concise doc comments on public views/types explaining behaviour and rationale (the *why*,
  not the *what*).

---

## Public API shape (host-facing)

- `CalendarRangePickerView` + `CalendarPickerConfiguration` (going/return dates, holidays, locale
  tag, `maxSelectableDate`, `isReturn`) + completion returning `CalendarPickerResult(going, return)`.
- Factories `CalendarRangePickerView.rangeSelector / .hotel / .rentACar` for common presets.
- `.calendarRangePicker(isPresented:…)` sheet modifier; `async CalendarPickerHosting.present(…)`;
  `streamingSelection` (live `AsyncStream`); `.calendarTheme(_:)` / `.calendarStyle(_:)` for design.
- `CalendarPickerHosting` — UIKit bridge to present from UIKit code.

Optional features (dark mode/theme, accessibility, `@SceneStorage` persistence, blocked dates, price
badges, min/max nights, single-date mode, RTL/locales) are **additive and opt-in** — their defaults
preserve the standard behaviour. Don't let them change the default behaviour.

Composability & layout: `.calendarDay` / `.calendarMonthHeader` / `.calendarWeekdayHeader` /
`.calendarLegend` content overrides fed a public `CalendarDayContext`; `horizontalPaging`,
`firstWeekday`; `CalendarController.scroll(to:)`; `CalendarYearView`. Chrome visibility is one
`CalendarChrome` on the config (title bar / date row / weekday header / legend / footer / Clear /
Apply — each independent); `.full` = stock, `.none` = bare grid. `CalendarGridView` is the pure-grid
drop-in. Content overrides are carried in the environment but **passed explicitly into the
HorizonCalendar-hosted cells** (the hosting boundary drops the environment) — keep that pattern.

Design config: one `CalendarStyle` (`theme` + `typography` + `metrics`) injected via
`.calendarStyle(_:)` drives ALL visuals. Components read `@Environment(\.calendarStyle)`; hosted
cells (`CalendarDayIndicator`, `DayOfWeekHeaderCell`) take `style` explicitly. **Every
metric/typography default must equal the original hardcoded value** — the snapshot tests assert the
stock look is unchanged, so don't drift defaults.

Input dates use `ETSCalendarDate(day, month, year)` / `HolidayEntry(dates, colorARGB, description)`.

---

## Build & run

- Library: `xcodebuild test -scheme Almanac -destination 'platform=iOS Simulator,name=iPhone 17'`
  (from repo root), or `swift test`.
- Demo app: `cd Demo && xcodebuild -scheme CalendarDemo -project calendar-ios.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 17' build`,
  or open `Demo/calendar-ios.xcodeproj` in Xcode and run the `CalendarDemo` scheme.
- Target: iOS 17, simulator (no signing).

---

## Do / Don't

- ✅ Keep date math timezone-stable via `CalDate`/`CalMonth`; never leak `Date`/TimeZone bugs into
  selection logic.
- ✅ Keep visual defaults pixel-stable — the snapshot suite enforces this.
- ✅ Write full files (complete, copy-paste-runnable).
- ❌ Don't add persistence/networking/DI/background frameworks the component doesn't need.
- ❌ Don't change selection/date/timezone behaviour without a covering test.
