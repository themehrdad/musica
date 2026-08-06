import SwiftUI
import SwiftData

@main
struct MusicaApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            rootView
                // A subscription can lapse while the app sits in the
                // background, and StoreKit posts nothing when it does — the
                // transaction simply stops appearing in currentEntitlements.
                // Re-checking on every foreground is what makes premium
                // switch off on time. Reads the local cache, so it's cheap.
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    Task { await StoreService.shared.refreshEntitlement() }
                }
        }
        .modelContainer(for: [Profile.self, DailyProgress.self],
                        inMemory: isDemo)
    }

    @ViewBuilder
    private var rootView: some View {
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

    private var isDemo: Bool {
#if DEBUG
        DemoScreen.fromArguments() != nil
#else
        false
#endif
    }
}
