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

    @Relationship(deleteRule: .cascade, inverse: \DailyProgress.profile)
    var dailyProgress: [DailyProgress]? = []

    var clefMode: ClefMode {
        get { ClefMode(rawValue: clefModeRaw) ?? .treble }
        set { clefModeRaw = newValue.rawValue }
    }

    init(name: String, avatarData: Data? = nil, beginner: Bool = true, clefMode: ClefMode = .treble) {
        self.name = name
        self.avatarData = avatarData
        self.createdAt = .now
        self.beginner = beginner
        self.clefModeRaw = clefMode.rawValue
    }
}
