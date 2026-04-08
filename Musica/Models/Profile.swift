import Foundation
import SwiftData

@Model
final class Profile {
    var name: String
    @Attribute(.externalStorage) var avatarData: Data?
    var createdAt: Date

    init(name: String, avatarData: Data? = nil) {
        self.name = name
        self.avatarData = avatarData
        self.createdAt = .now
    }
}
