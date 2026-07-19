import Foundation
import SwiftData

@Model
final class DailyProgress {
    var date: String          // "2026-04-07" format for easy daily lookup
    var notesCompleted: Int
    var profile: Profile?
    // Correctly played notes in practice order, comma-separated ("C4,E4,G4").
    // Empty for days recorded before note tracking existed.
    var practicedNotesRaw: String = ""
    // The profile's daily goal as of the last practice that day. Stars are
    // judged against the goal that applied then, not today's setting. The
    // default doubles as history: before goals were per-profile, it was 20.
    var goal: Int = 20

    init(date: String, notesCompleted: Int = 0, goal: Int = 20, profile: Profile) {
        self.date = date
        self.notesCompleted = notesCompleted
        self.goal = goal
        self.profile = profile
    }

    var practicedNotes: [String] {
        get { practicedNotesRaw.isEmpty ? [] : practicedNotesRaw.components(separatedBy: ",") }
        set { practicedNotesRaw = newValue.joined(separator: ",") }
    }

    func recordNote(_ displayName: String) {
        practicedNotes.append(displayName)
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// Key for a calendar day, matching the format `date` is stored in.
    static func dayString(from date: Date) -> String {
        dayFormatter.string(from: date)
    }

    static func todayString() -> String {
        dayString(from: .now)
    }
}
