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
        ZStack {
            // Main content
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

                // Mic indicator (tap to toggle)
                Button {
                    if vm.audioService.isListening {
                        vm.stopListening()
                    } else {
                        try? vm.startListening()
                    }
                } label: {
                    MicIndicatorView(
                        amplitude: vm.audioService.amplitude,
                        isListening: vm.audioService.isListening
                    )
                }
                .padding(.bottom, 40)
            }

            // Animation overlays
            if vm.state == .correct {
                ConfettiView()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            if vm.state == .wrong {
                SadFaceView()
                    .transition(.scale.combined(with: .opacity))
            }

            if vm.state == .goalReached {
                goalReachedOverlay
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: vm.state)
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

    private var goalReachedOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("👑")
                    .font(.system(size: 80))
                Text("Daily Goal Reached!")
                    .font(.title.bold())
                    .foregroundStyle(.primary)
                Text("\(vm.completedToday) notes practiced")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("Keep Practicing") {
                    vm.continueAfterGoal()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}
