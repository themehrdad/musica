import Foundation
import SwiftData
import UIKit

enum PracticeState: Equatable {
    case listening
    case correct
    case wrong
    case goalReached
}

@MainActor
@Observable
final class PracticeViewModel {
    var currentCard: PracticeCard
    var state: PracticeState = .listening
    var completedToday: Int = 0
    var wrongAttempts: Int = 0
    var showNoteName: Bool = false
    var showPianoHint: Bool = false
    // Set at the crown moment when the learner has earned a rating ask.
    var shouldRequestReview = false

    var currentNote: MusicNote { currentCard.note }

    let profile: Profile
    let audioService = AudioService()

    private var modelContext: ModelContext?
    private var isProcessing = false
    private let deck: PracticeDeck
    private let premiumStatus: () -> Bool
    private let gatingEnabled: Bool

    var dailyGoal: Int {
        FreeTier.practiceGoal(requested: profile.dailyGoal, premium: premiumStatus(),
                              gatingEnabled: gatingEnabled)
    }

    var canPracticeMore: Bool {
        FreeTier.canPracticeMore(completedToday: completedToday, premium: premiumStatus(),
                                 gatingEnabled: gatingEnabled)
    }

    /// Let feedback and the crown finish before presenting the free limit.
    var showFreeLimit: Bool {
        !canPracticeMore && state != .correct && state != .goalReached
    }

    init(profile: Profile, gatingEnabled: Bool = Config.premiumGatingEnabled,
         premiumStatus: @escaping () -> Bool = { StoreService.shared.isPremium }) {
        self.profile = profile
        self.gatingEnabled = gatingEnabled
        self.premiumStatus = premiumStatus
        let deck = PracticeDeck(profile: profile)
        self.deck = deck
        self.currentCard = deck.draw()
    }

    func setup(context: ModelContext) {
        self.modelContext = context
        loadTodayProgress()
    }

    func startListening() throws {
        try audioService.start()
    }

    func stopListening() {
        audioService.stop()
    }

    func evaluateNote(_ detected: MusicNote) {
        guard state == .listening, !isProcessing else { return }
        guard canPracticeMore else { return }
        isProcessing = true
        GateLog.log("evaluate detected=\(detected.displayName) target=\(currentNote.displayName) -> \(detected.midiNumber == currentNote.midiNumber ? "CORRECT" : "WRONG")")

        if detected.midiNumber == currentNote.midiNumber {
            state = .correct
            completedToday += 1
            wrongAttempts = 0
            showNoteName = false
            showPianoHint = false
            saveTodayProgress(noting: currentNote)

            if completedToday == dailyGoal {
                haptic(.success)
                // Today's save above just became a goal day, so this is
                // where the third one is detected — right at the crown.
                if let context = modelContext {
                    shouldRequestReview = RatingPrompter.goalDaysReached(profile: profile, context: context)
                        >= RatingPrompter.goalDaysBeforeAsking
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    self?.state = .goalReached
                }
            } else {
                haptic(.success)
                advanceAfterDelay()
            }
        } else {
            state = .wrong
            haptic(.error)
            wrongAttempts += 1
            if wrongAttempts >= Config.wrongAttemptsBeforeHint * 2 {
                showPianoHint = true
            } else if wrongAttempts >= Config.wrongAttemptsBeforeHint {
                showNoteName = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.state = .listening
                self?.isProcessing = false
            }
        }
    }

    func nextNote() {
        currentCard = deck.draw(avoiding: currentCard)
        state = .listening
        wrongAttempts = 0
        showNoteName = false
        showPianoHint = false
        isProcessing = false
    }

    func continueAfterGoal() {
        state = .listening
        isProcessing = false
        nextNote()
    }

    private func haptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    private func advanceAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.nextNote()
        }
    }

    private func loadTodayProgress() {
        guard let context = modelContext else { return }
        let today = DailyProgress.todayString()
        let descriptor = FetchDescriptor<DailyProgress>(
            predicate: #Predicate { $0.date == today }
        )
        let results = (try? context.fetch(descriptor)) ?? []
        let profileID = profile.persistentModelID
        completedToday = results.first { $0.profile?.persistentModelID == profileID }?.notesCompleted ?? 0
    }

    private func saveTodayProgress(noting note: MusicNote) {
        guard let context = modelContext else { return }
        let today = DailyProgress.todayString()
        let descriptor = FetchDescriptor<DailyProgress>(
            predicate: #Predicate { $0.date == today }
        )
        let results = (try? context.fetch(descriptor)) ?? []
        let profileID = profile.persistentModelID
        if let existing = results.first(where: { $0.profile?.persistentModelID == profileID }) {
            existing.notesCompleted = completedToday
            existing.goal = dailyGoal
            existing.recordNote(note.displayName)
        } else {
            let progress = DailyProgress(date: today, notesCompleted: completedToday,
                                         goal: dailyGoal, profile: profile)
            progress.recordNote(note.displayName)
            context.insert(progress)
        }
        try? context.save()
    }
}
