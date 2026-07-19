import Foundation
import SwiftData

enum ClefMode: String, Codable, CaseIterable {
    case treble = "Treble"
    case bass = "Bass"
    case both = "Both"
}

@Model
final class Profile {
    var name: String
    @Attribute(.externalStorage) var avatarData: Data?
    var createdAt: Date
    var beginner: Bool = true
    var clefModeRaw: String = "treble"
    // Notes to practice per day. Also stamped into each day's DailyProgress
    // so past stars keep the goal that applied at the time.
    var dailyGoal: Int = Config.dailyGoal
    // Custom practice keys per hand (MIDI numbers). Empty = not customized;
    // note generation falls back to the beginner/full default ranges.
    var trebleKeysRaw: [Int] = []
    var bassKeysRaw: [Int] = []

    @Relationship(deleteRule: .cascade, inverse: \DailyProgress.profile)
    var dailyProgress: [DailyProgress]? = []

    var clefMode: ClefMode {
        get { ClefMode(rawValue: clefModeRaw) ?? .treble }
        set { clefModeRaw = newValue.rawValue }
    }

    /// Customized right-hand keys, sorted, naturals only. Empty = use defaults.
    var trebleKeys: [Int] {
        get { Self.sanitized(trebleKeysRaw) }
        set { trebleKeysRaw = Self.sanitized(newValue) }
    }

    /// Customized left-hand keys, sorted, naturals only. Empty = use defaults.
    var bassKeys: [Int] {
        get { Self.sanitized(bassKeysRaw) }
        set { bassKeysRaw = Self.sanitized(newValue) }
    }

    private static func sanitized(_ keys: [Int]) -> [Int] {
        Array(Set(keys.filter { MusicNote(midiNumber: $0) != nil })).sorted()
    }

    init(name: String, avatarData: Data? = nil, beginner: Bool = true, clefMode: ClefMode = .treble,
         trebleKeys: [Int] = [], bassKeys: [Int] = [], dailyGoal: Int = Config.dailyGoal) {
        self.name = name
        self.avatarData = avatarData
        self.createdAt = .now
        self.beginner = beginner
        self.clefModeRaw = clefMode.rawValue
        self.trebleKeysRaw = Self.sanitized(trebleKeys)
        self.bassKeysRaw = Self.sanitized(bassKeys)
        self.dailyGoal = max(1, dailyGoal)
    }
}
