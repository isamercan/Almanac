import SwiftUI

// iOS-style drum time pickers. / `TimeWheelAmPm`,
// including the soft min/max snap-back behaviour. The wheel itself is `WheelColumn`.
// NOTE: this component is standalone (not wired into the calendar screen); it is
// ported for module parity and shown on its own page in the demo app.

/// Convert a 12-hour clock value (1…12 + AM/PM) to a 24-hour hour (0…23). (Internal for tests.)
func to24Hour(_ hour12: Int, isAm: Bool) -> Int {
  (hour12 % 12) + (isAm ? 0 : 12)
}

/// Convert a 24-hour hour (0…23) back to a 12-hour value: (hour 1…12, isAm). (Internal for tests.)
func from24Hour(_ hour24: Int) -> (hour12: Int, isAm: Bool) {
  let isAm = hour24 < 12
  let h = hour24 % 12
  return (h == 0 ? 12 : h, isAm)
}

// MARK: - 24-hour wheel

public struct TimeWheel24: View {
  let hour: Int
  let minute: Int
  let onTimeChanged: (_ hour: Int, _ minute: Int) -> Void
  var minHour: Int?
  var minMinute: Int?
  var maxHour: Int?
  var maxMinute: Int?
  var config: TimePickerConfig

  public init(
    hour: Int,
    minute: Int,
    onTimeChanged: @escaping (_ hour: Int, _ minute: Int) -> Void,
    minHour: Int? = nil,
    minMinute: Int? = nil,
    maxHour: Int? = nil,
    maxMinute: Int? = nil,
    config: TimePickerConfig = TimePickerConfig())
  {
    self.hour = hour
    self.minute = minute
    self.onTimeChanged = onTimeChanged
    self.minHour = minHour
    self.minMinute = minMinute
    self.maxHour = maxHour
    self.maxMinute = maxMinute
    self.config = config
  }

  public var body: some View {
    let effMinHour = minHour ?? 0
    let effMinMinute = minMinute ?? 0
    let effMaxHour = maxHour ?? 23
    let effMaxMinute = maxMinute ?? 59

    ZStack {
      // Selection highlight band.
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(argb: 0x34747480))
        .frame(height: config.itemHeight)
        .padding(.horizontal, 16)

      HStack(spacing: 0) {
        WheelColumn(
          items: (0...23).map { String(format: "%02d", $0) },
          selectedIndex: hour,
          onSelectedChanged: { newHour in
            var corrected = newHour
            if minHour != nil { corrected = max(corrected, effMinHour) }
            if maxHour != nil { corrected = min(corrected, effMaxHour) }
            let correctedMinute: Int
            if minHour != nil && corrected == effMinHour {
              correctedMinute = max(minute, effMinMinute)
            } else if maxHour != nil && corrected == effMaxHour {
              correctedMinute = min(minute, effMaxMinute)
            } else {
              correctedMinute = minute
            }
            onTimeChanged(corrected, correctedMinute)
          },
          textAlignment: .trailing,
          textPadding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12),
          config: config,
          isIndexDisabled: { index in
            (minHour != nil && index < effMinHour) || (maxHour != nil && index > effMaxHour)
          },
          accessibilityLabel: L10n.string(L10n.Key.a11yHourColumn, locale: .current))
        .frame(maxWidth: .infinity)

        Spacer().frame(width: 24)

        WheelColumn(
          items: (0...59).map { String(format: "%02d", $0) },
          selectedIndex: minute,
          onSelectedChanged: { newMinute in
            let correctedMinute: Int
            if minHour != nil && hour == effMinHour {
              correctedMinute = max(newMinute, effMinMinute)
            } else if maxHour != nil && hour == effMaxHour {
              correctedMinute = min(newMinute, effMaxMinute)
            } else {
              correctedMinute = newMinute
            }
            onTimeChanged(hour, correctedMinute)
          },
          textAlignment: .leading,
          textPadding: EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0),
          config: config,
          isIndexDisabled: { index in
            (minHour != nil && hour == effMinHour && index < effMinMinute) ||
              (maxHour != nil && hour == effMaxHour && index > effMaxMinute)
          },
          accessibilityLabel: L10n.string(L10n.Key.a11yMinuteColumn, locale: .current))
        .frame(maxWidth: .infinity)
      }
    }
    .frame(height: config.wheelHeight)
  }
}

// MARK: - 12-hour (AM/PM) wheel

public struct TimeWheelAmPm: View {
  /// Hour in 12-hour form (1…12).
  let hour: Int
  let minute: Int
  let isAm: Bool
  let onTimeChanged: (_ hour: Int, _ minute: Int, _ isAm: Bool) -> Void
  /// Min/max are expressed in 24-hour terms, same as `TimeWheel24`.
  var minHour: Int?
  var minMinute: Int?
  var maxHour: Int?
  var maxMinute: Int?
  var config: TimePickerConfig

  public init(
    hour: Int,
    minute: Int,
    isAm: Bool,
    onTimeChanged: @escaping (_ hour: Int, _ minute: Int, _ isAm: Bool) -> Void,
    minHour: Int? = nil,
    minMinute: Int? = nil,
    maxHour: Int? = nil,
    maxMinute: Int? = nil,
    config: TimePickerConfig = TimePickerConfig())
  {
    self.hour = hour
    self.minute = minute
    self.isAm = isAm
    self.onTimeChanged = onTimeChanged
    self.minHour = minHour
    self.minMinute = minMinute
    self.maxHour = maxHour
    self.maxMinute = maxMinute
    self.config = config
  }

  public var body: some View {
    let effMinHour = minHour ?? 0
    let effMinMinute = minMinute ?? 0
    let effMaxHour = maxHour ?? 23
    let effMaxMinute = maxMinute ?? 59

    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(argb: 0x14747480))
        .frame(height: config.itemHeight)

      HStack(spacing: 0) {
        // Hour 1…12
        WheelColumn(
          items: (1...12).map { String($0) },
          selectedIndex: hour - 1,
          onSelectedChanged: { index in
            let newHour24 = to24Hour(index + 1, isAm: isAm)
            var corrected = newHour24
            if minHour != nil { corrected = max(corrected, effMinHour) }
            if maxHour != nil { corrected = min(corrected, effMaxHour) }
            let correctedMinute = boundaryMinute(forHour24: corrected, minute: minute,
                                                 effMinHour: effMinHour, effMinMinute: effMinMinute,
                                                 effMaxHour: effMaxHour, effMaxMinute: effMaxMinute)
            let (h12, am) = from24Hour(corrected)
            onTimeChanged(h12, correctedMinute, am)
          },
          textAlignment: .trailing,
          config: config,
          isIndexDisabled: { index in
            let h24 = to24Hour(index + 1, isAm: isAm)
            return (minHour != nil && h24 < effMinHour) || (maxHour != nil && h24 > effMaxHour)
          },
          accessibilityLabel: L10n.string(L10n.Key.a11yHourColumn, locale: .current))
        .frame(maxWidth: .infinity)

        // Minute 0…59
        WheelColumn(
          items: (0...59).map { String(format: "%02d", $0) },
          selectedIndex: minute,
          onSelectedChanged: { newMinute in
            let h24 = to24Hour(hour, isAm: isAm)
            let correctedMinute: Int
            if minHour != nil && h24 == effMinHour {
              correctedMinute = max(newMinute, effMinMinute)
            } else if maxHour != nil && h24 == effMaxHour {
              correctedMinute = min(newMinute, effMaxMinute)
            } else {
              correctedMinute = newMinute
            }
            onTimeChanged(hour, correctedMinute, isAm)
          },
          textAlignment: .center,
          config: config,
          isIndexDisabled: { index in
            let h24 = to24Hour(hour, isAm: isAm)
            return (minHour != nil && h24 == effMinHour && index < effMinMinute) ||
              (maxHour != nil && h24 == effMaxHour && index > effMaxMinute)
          },
          accessibilityLabel: L10n.string(L10n.Key.a11yMinuteColumn, locale: .current))
        .frame(maxWidth: .infinity)

        // AM / PM
        WheelColumn(
          items: ["AM", "PM"],
          selectedIndex: isAm ? 0 : 1,
          onSelectedChanged: { index in
            let newIsAm = index == 0
            let newHour24 = to24Hour(hour, isAm: newIsAm)
            var corrected = newHour24
            if minHour != nil { corrected = max(corrected, effMinHour) }
            if maxHour != nil { corrected = min(corrected, effMaxHour) }
            let correctedMinute = boundaryMinute(forHour24: corrected, minute: minute,
                                                 effMinHour: effMinHour, effMinMinute: effMinMinute,
                                                 effMaxHour: effMaxHour, effMaxMinute: effMaxMinute)
            let (h12, am) = from24Hour(corrected)
            onTimeChanged(h12, correctedMinute, am)
          },
          textAlignment: .leading,
          config: config,
          isIndexDisabled: { index in
            if index == 0 {
              return (minHour != nil && effMinHour >= 12)
            } else {
              return (maxHour != nil && effMaxHour < 12)
            }
          },
          accessibilityLabel: L10n.string(L10n.Key.a11yAmPmColumn, locale: .current))
        .frame(maxWidth: .infinity)
      }
    }
    .frame(height: config.wheelHeight)
  }

  /// Clamp the minute when the corrected hour sits on the min/max boundary hour.
  private func boundaryMinute(
    forHour24 hour24: Int, minute: Int,
    effMinHour: Int, effMinMinute: Int, effMaxHour: Int, effMaxMinute: Int) -> Int
  {
    if minHour != nil && hour24 == effMinHour { return max(minute, effMinMinute) }
    if maxHour != nil && hour24 == effMaxHour { return min(minute, effMaxMinute) }
    return minute
  }
}
