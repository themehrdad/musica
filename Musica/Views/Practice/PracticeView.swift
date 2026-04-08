import SwiftUI
import SwiftData

struct PracticeView: View {
    let profile: Profile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var currentNote: MusicNote?
    @State private var completedToday: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Top bar: back button + profile + counter
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
                CounterView(completed: completedToday, goal: Config.dailyGoal)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()

            // Staff
            StaffView(note: currentNote)
                .padding(.horizontal, 8)

            // Note name
            if let note = currentNote {
                Text(note.displayName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }

            Spacer()

            // Mic indicator placeholder
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue.opacity(0.6))
                .padding(.bottom, 8)

            Text("Listening...")
                .font(.caption)
                .foregroundStyle(.secondary)

            // DEBUG: Next note button (removed in Phase 3)
            Button("Next Note (Debug)") {
                currentNote = MusicNote.random(beginner: profile.beginner)
            }
            .padding()
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .onAppear {
            currentNote = MusicNote.random(beginner: profile.beginner)
            loadTodayProgress()
        }
    }

    private func loadTodayProgress() {
        let today = DailyProgress.todayString()
        let descriptor = FetchDescriptor<DailyProgress>(
            predicate: #Predicate { $0.date == today }
        )
        let results = (try? context.fetch(descriptor)) ?? []
        let profileID = profile.persistentModelID
        completedToday = results.first { $0.profile?.persistentModelID == profileID }?.notesCompleted ?? 0
    }
}
