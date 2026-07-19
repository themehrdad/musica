import SwiftUI
import SwiftData

@main
struct MusicaApp: App {
    var body: some Scene {
        WindowGroup {
#if DEBUG
            if let mode = DemoScreen.fromArguments() {
                DemoRootView(mode: mode)
            } else {
                ProfileListView()
            }
#else
            ProfileListView()
#endif
        }
        .modelContainer(for: [Profile.self, DailyProgress.self],
                        inMemory: isDemo)
    }

    private var isDemo: Bool {
#if DEBUG
        DemoScreen.fromArguments() != nil
#else
        false
#endif
    }
}
