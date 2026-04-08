import SwiftUI
import SwiftData

@main
struct MusicaApp: App {
    var body: some Scene {
        WindowGroup {
            ProfileListView()
        }
        .modelContainer(for: [Profile.self, DailyProgress.self])
    }
}
