import SwiftUI

/// A kid's space in the app: the practice screen plus their progress
/// calendar, as tabs. Presented full-screen from the profile list.
struct ProfileHomeView: View {
    let profile: Profile

    var body: some View {
        TabView {
            PracticeView(profile: profile)
                .tabItem {
                    Label("Practice", systemImage: "music.note")
                }

            ProgressCalendarView(profile: profile)
                .tabItem {
                    Label("Progress", systemImage: "calendar")
                }
        }
    }
}
