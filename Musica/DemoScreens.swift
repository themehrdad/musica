#if DEBUG
import SwiftData
import SwiftUI

/// App Store screenshot support, DEBUG builds only. Launching with
/// `-demo-screen <mode>` swaps the real database for an in-memory one
/// seeded with friendly demo data and jumps straight to the target screen:
///
///   xcrun simctl launch <sim> com.higgssoftware.musica -demo-screen progress
///
/// Modes: profiles, practice, grand, progress, paywall, paywall-yearly.
/// `paywall` shows the standard two-plan picker; `paywall-yearly` shows
/// only the yearly plan (for the yearly product's IAP review screenshot).
enum DemoScreen: String {
    case profiles, practice, grand, progress, paywall, paywallYearly = "paywall-yearly"

    static func fromArguments() -> DemoScreen? {
        let args = ProcessInfo.processInfo.arguments
        guard let flag = args.firstIndex(of: "-demo-screen"),
              args.indices.contains(flag + 1) else { return nil }
        return DemoScreen(rawValue: args[flag + 1])
    }
}

struct DemoRootView: View {
    let mode: DemoScreen
    @Environment(\.modelContext) private var context
    @State private var maya: Profile?
    @State private var leo: Profile?

    var body: some View {
        // The background anchors onAppear even while the seeded profiles are
        // still nil — a bare EmptyView would never fire it.
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            switch mode {
            case .profiles:
                ProfileListView()
            case .practice:
                if let maya { PracticeView(profile: maya) }
            case .grand:
                if let leo { PracticeView(profile: leo) }
            case .progress:
                if let maya { ProgressCalendarView(profile: maya) }
            case .paywall:
                PaywallView()
            case .paywallYearly:
                PaywallView(singleProductID: Config.yearlyProductID)
            }
        }
        .onAppear(perform: seed)
    }

    private func seed() {
        guard maya == nil else { return }

        let kid1 = Profile(name: "Maya", beginner: true, clefMode: .treble)
        let kid2 = Profile(name: "Leo", beginner: false, clefMode: .both)
        context.insert(kid1)
        context.insert(kid2)

        // A lively practice month: strong streaks, a few misses, plenty of
        // gold-star days, and a today that's mid-practice with note history.
        let calendar = Calendar.current
        let scores = [20, 22, 12, 20, 0, 8, 20, 21, 15, 20, 20, 5, 18, 20, 25, 0, 20, 14, 20, 20]
        for (offset, score) in scores.enumerated() where score > 0 {
            guard let day = calendar.date(byAdding: .day, value: -(offset + 1), to: .now) else { continue }
            let progress = DailyProgress(date: DailyProgress.dayString(from: day),
                                         notesCompleted: score, goal: 20, profile: kid1)
            context.insert(progress)
        }
        let today = DailyProgress(date: DailyProgress.todayString(),
                                  notesCompleted: 14, goal: 20, profile: kid1)
        today.practicedNotes = ["C4", "D4", "E4", "C4", "F4", "G4", "E4", "A4",
                                "F4", "C4", "B4", "G4", "D4", "E4"]
        context.insert(today)
        try? context.save()

        maya = kid1
        leo = kid2
    }
}
#endif
