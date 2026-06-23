# ``Almanac``

A self-contained SwiftUI date-range calendar picker, plus a standalone wheel time picker.

## Overview

`Almanac` presents a vertical, scrolling month grid for picking a departure/return date range
(or a single date), with holiday indicators, an animated legend, dark mode, Dynamic Type, RTL, and
full VoiceOver support. The scrolling engine is Airbnb HorizonCalendar; all day-cell visuals and the
selection state machine are Almanac's own.

Present it in SwiftUI:

```swift
import Almanac

struct DemoView: View {
  @State private var show = false
  var body: some View {
    Button("Pick dates") { show = true }
      .calendarRangePicker(
        isPresented: $show,
        configuration: CalendarPickerConfiguration(localeTag: "tr")) { result in
          // result.goingDate / result.returnDate
        }
  }
}
```

…or from UIKit with `async`:

```swift
let result = await CalendarPickerHosting.present(configuration: config, from: self)
```

## Topics

### Presenting the picker

- ``CalendarRangePickerView``
- ``CalendarPickerConfiguration``
- ``CalendarPickerResult``
- ``CalendarSelectionMode``
- ``CalendarController``

### Composition & layout

- ``CalendarChrome``
- ``CalendarGridView``
- ``CalendarDayContext``
- ``CalendarYearView``

### Input model

- ``HolidayEntry``
- ``ETSCalendarDate``

### Theming & design

- ``CalendarStyle``
- ``CalendarTheme``
- ``CalendarColors``
- ``CalendarTypography``
- ``CalendarMetrics``
- ``CalendarDayShape``
- ``CalendarTextStyle``
- ``CalendarStyleConfigurator``

### Time picker

- ``TimeWheel24``
- ``TimeWheelAmPm``
- ``TimePickerConfig``
