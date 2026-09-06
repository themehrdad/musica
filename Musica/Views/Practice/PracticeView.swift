import SwiftUI
import SwiftData
import StoreKit

struct PracticeView: View {
    let profile: Profile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.requestReview) private var requestReview
    @AppStorage("rating.lastRequestedAt") private var lastReviewRequest = 0.0
    @State private var audioError: String?
    @State private var vm: PracticeViewModel

    init(profile: Profile, gatingEnabled: Bool = Config.premiumGatingEnabled) {
        self.profile = profile
        self._vm = State(initialValue: PracticeViewModel(profile: profile, gatingEnabled: gatingEnabled))
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
                    CounterView(completed: vm.completedToday, goal: vm.dailyGoal)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                Text("Play this note on your piano")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 24)

                // Staff
                StaffView(note: vm.currentNote, clefMode: profile.clefMode,
                          noteStaff: vm.currentCard.staff)
                    .padding(.horizontal, 8)

                // Note name (shown after 3 wrong attempts)
                if vm.showNoteName {
                    Text(vm.currentNote.displayName)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .transition(.opacity)
                }

                // Piano hint (shown after 6 wrong attempts)
                if vm.showPianoHint {
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
                        startListening()
                    }
                } label: {
                    MicIndicatorView(
                        amplitude: vm.audioService.amplitude,
                        isListening: vm.audioService.isListening
                    )
                }
                .accessibilityLabel(vm.audioService.isListening ? "Pause microphone" : "Start microphone")
                .padding(.bottom, 12)

                Text("Place your iPhone near the piano.\nFor a digital piano, turn its speakers on.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
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

            if vm.showFreeLimit {
                FreeLimitReachedView(onDone: { dismiss() })
                    .transition(.opacity)
            }
        }
        .animation(.spring(duration: 0.3), value: vm.state)
        .background(Color(.systemBackground))
        .onAppear {
            vm.setup(context: context)
#if DEBUG
            if let demo = DemoScreen.fromArguments() {
                vm.currentCard = PracticeCard(note: MusicNote(midiNumber: 64)!, staff: .treble)
                vm.audioService.isListening = true
                if demo == .hints {
                    vm.showNoteName = true
                    vm.showPianoHint = true
                } else if demo == .goal {
                    vm.completedToday = 20
                    vm.state = .goalReached
                }
            }
#endif
            startListening()
        }
        .onDisappear {
            vm.stopListening()
        }
        .onChange(of: vm.audioService.detectedNote) { _, newNote in
            if let note = newNote {
                vm.evaluateNote(note)
            }
        }
        .task(id: vm.state) {
            guard vm.state == .goalReached, vm.shouldRequestReview else { return }
            // Cancel when the learner continues or leaves the screen.
            do { try await Task.sleep(for: .seconds(3)) } catch { return }
            let previous = lastReviewRequest == 0 ? nil : Date(timeIntervalSince1970: lastReviewRequest)
            guard RatingPrompter.mayRequest(lastRequested: previous) else { return }
            lastReviewRequest = Date.now.timeIntervalSince1970
            requestReview()
        }
        .alert("Microphone unavailable", isPresented: Binding(
            get: { audioError != nil }, set: { if !$0 { audioError = nil } }
        )) {
            Button("OK", role: .cancel) { audioError = nil }
        } message: {
            Text("Allow microphone access for Musica in Settings, then tap the microphone to try again.")
        }
    }

    private func startListening() {
#if DEBUG
        if DemoScreen.fromArguments() != nil { return }
#endif
        do { try vm.startListening() } catch { audioError = error.localizedDescription }
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
                Button(vm.canPracticeMore ? "Keep Practicing" : "Done for today") {
                    if vm.canPracticeMore {
                        vm.continueAfterGoal()
                    } else {
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                if !vm.canPracticeMore {
                    Text("Your \(Config.freeDailyNoteLimit) free notes will be ready again tomorrow.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}
