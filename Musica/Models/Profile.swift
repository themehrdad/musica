import Foundation
import SwiftData

@Model
final class Profile {
    var name: String
    @Attribute(.externalStorage) var avatarData: Data?
    var createdAt: Date
    var beginner: Bool = true

    @Relationship(deleteRule: .cascade, inverse: \DailyProgress.profile)
    var dailyProgress: [DailyProgress]? = []

    init(name: String, avatarData: Data? = nil, beginner: Bool = true) {
        self.name = name
        self.avatarData = avatarData
        self.createdAt = .now
        self.beginner = beginner
    }
}
