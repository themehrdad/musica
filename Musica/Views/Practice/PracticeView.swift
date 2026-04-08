import SwiftUI

struct PracticeView: View {
    let profile: Profile
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 8) {
                        AvatarView(name: profile.name,
                                   imageData: profile.avatarData, size: 36)
                        Text(profile.name)
                            .font(.headline)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()

            Image(systemName: "music.note")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Practice Screen")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("Coming in Phase 2")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .background(Color(.systemBackground))
    }
}
