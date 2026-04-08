import Foundation
import SwiftData

@Model
final class Profile {
    var name: String
    @Attribute(.externalStorage) var avatarData: Data?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \DailyProgress.profile)
    var dailyProgress: [DailyProgress]? = []

    init(name: String, avatarData: Data? = nil) {
        self.name = name
        self.avatarData = avatarData
        self.createdAt = .now
    }
}
