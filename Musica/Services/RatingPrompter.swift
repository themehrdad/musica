import Foundation
import SwiftData

/// Decides when the app should ask for an App Store rating.
///
/// The ask lands on a win: a day counts only when the learner reached their
/// daily goal, and the prompt waits until they have done that on
/// `goalDaysBeforeAsking` different days. Requests are spaced across the
/// whole device, even when siblings switch profiles. Apple decides
/// whether the system dialog actually appears.
enum RatingPrompter {
    static let goalDaysBeforeAsking = 3
    static let requestInterval: TimeInterval = 120 * 24 * 60 * 60

    static func mayRequest(lastRequested: Date?, now: Date = .now) -> Bool {
        guard let lastRequested else { return true }
        return now.timeIntervalSince(lastRequested) >= requestInterval
    }

    /// Distinct days on which this profile reached its daily goal.
    /// Judged against each day's stored goal for the same reason the
    /// Progress stars are: the goal that applied then, not today's.
    static func goalDaysReached(profile: Profile, context: ModelContext) -> Int {
        let all = (try? context.fetch(FetchDescriptor<DailyProgress>())) ?? []
        let profileID = profile.persistentModelID
        var reached = Set<String>()
        for progress in all where progress.profile?.persistentModelID == profileID {
            if progress.notesCompleted >= progress.goal {
                reached.insert(progress.date)
            }
        }
        return reached.count
    }
}
