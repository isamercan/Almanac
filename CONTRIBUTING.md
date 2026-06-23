# Contributing

Thanks for helping improve Almanac.

## Setup
- Xcode 16+ (developed on Xcode 26), iOS 17 simulator.
- Library: repo-root Swift package (`Package.swift`, sources under `Sources/Almanac/`). Example app +
  UI tests: `Demo/calendar-ios.xcodeproj`.

## Before opening a PR
1. **Tests must pass**
   ```bash
   xcodebuild test -scheme Almanac -destination 'platform=iOS Simulator,name=iPhone 17'
   cd Demo && xcodebuild test -scheme CalendarDemo -project calendar-ios.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
   ```
2. **Lint** (if installed): `swiftlint --strict`
3. **Snapshot tests** are machine/OS-specific. If an intentional visual change alters them, re-record
   with `withSnapshotTesting(record: .all)` and review the new references. CI skips them by default.
4. **Don't drift the defaults.** `CalendarStyle`/`CalendarMetrics`/`CalendarChrome` defaults must keep
   the stock look — the snapshot suite asserts this. New visual options ship disabled-by-default.
5. **Core behaviour.** The selection state machine, date bounds and timezone behaviour are locked by
   unit tests — change them only with an accompanying test and a note in the PR.
6. Update `CHANGELOG.md` under **Unreleased**.

## Conventions
- 2-space indentation; one component per file; concise doc comments on public API.
- Public surface is intentionally small — keep internal helpers `internal`.
- HorizonCalendar hosts day cells in their own hosting controllers, so pass `style` (and any
  env-dependent value) **explicitly** into the cells; the SwiftUI environment does not cross that boundary.
