import SwiftUI

/// Minimal host app — the runnable target that exercises Almanac (the analog of the source's
/// Activities / Compose previews). The library itself has no app entry point.
@main
struct CalendarDemoApp: App {
  var body: some Scene {
    WindowGroup {
      DemoMenuView()
    }
  }
}
