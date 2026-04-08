import SwiftUI
import SwiftData

struct PracticeView: View {
    let profile: Profile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var vm: PracticeViewModel

    init(profile: Profile) {
        self.profile = profile
        self._vm = State(initialValue: PracticeViewModel(profile: profile))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
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
                CounterView(completed: vm.completedToday, goal: Config.dailyGoal)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()

            // Staff
            StaffView(note: vm.currentNote)
                .padding(.horizontal, 8)

            // Note name
            Text(vm.currentNote.displayName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            // Piano hint
            if vm.showHint {
                PianoHintView(note: vm.currentNote)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.top, 16)
            }

            Spacer()

            // Feedback text
            Group {
                switch vm.state {
                case .correct:
                    Text("Correct!")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                case .wrong:
                    Text("Try again!")
                        .font(.title.bold())
                        .foregroundStyle(.red)
                case .goalReached:
                    VStack(spacing: 16) {
                        Text("Daily Goal Reached!")
                            .font(.title.bold())
                        Button("Keep Practicing") { vm.continueAfterGoal() }
                            .buttonStyle(.borderedProminent)
                    }
                case .listening:
                    EmptyView()
                }
            }
            .animation(.spring(duration: 0.3), value: vm.state)

            // Mic indicator
            MicIndicatorView(
                amplitude: vm.audioService.amplitude,
                isListening: vm.audioService.isListening
            )
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .onAppear {
            vm.setup(context: context)
            try? vm.startListening()
        }
        .onDisappear {
            vm.stopListening()
        }
        .onChange(of: vm.audioService.detectedNote) { _, newNote in
            if let note = newNote {
                vm.evaluateNote(note)
            }
        }
    }
}
