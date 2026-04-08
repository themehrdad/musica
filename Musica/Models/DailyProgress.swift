import Foundation
import SwiftData

@Model
final class DailyProgress {
    var date: String          // "2026-04-07" format for easy daily lookup
    var notesCompleted: Int
    var profile: Profile?

    init(date: String, notesCompleted: Int = 0, profile: Profile) {
        self.date = date
        self.notesCompleted = notesCompleted
        self.profile = profile
    }

    static func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: .now)
    }
}
