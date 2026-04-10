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
    var currentNote: MusicNote
    var state: PracticeState = .listening
    var completedToday: Int = 0
    var wrongAttempts: Int = 0
    var showNoteName: Bool = false
    var showPianoHint: Bool = false

    let profile: Profile
    let audioService = AudioService()

    private var modelContext: ModelContext?
    private var isProcessing = false
    private let isBeginner: Bool
    private let clefMode: ClefMode

    init(profile: Profile) {
        self.profile = profile
        self.isBeginner = profile.beginner
        self.clefMode = profile.clefMode
        self.currentNote = MusicNote.random(beginner: profile.beginner, clefMode: profile.clefMode)
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
        isProcessing = true

        if detected.midiNumber == currentNote.midiNumber {
            state = .correct
            completedToday += 1
            wrongAttempts = 0
            showNoteName = false
            showPianoHint = false
            saveTodayProgress()

            if completedToday == Config.dailyGoal {
                haptic(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.state = .listening
                self?.isProcessing = false
            }
        }
    }

    func nextNote() {
        currentNote = MusicNote.random(beginner: isBeginner, clefMode: clefMode)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
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

    private func saveTodayProgress() {
        guard let context = modelContext else { return }
        let today = DailyProgress.todayString()
        let descriptor = FetchDescriptor<DailyProgress>(
            predicate: #Predicate { $0.date == today }
        )
        let results = (try? context.fetch(descriptor)) ?? []
        let profileID = profile.persistentModelID
        if let existing = results.first(where: { $0.profile?.persistentModelID == profileID }) {
            existing.notesCompleted = completedToday
        } else {
            let progress = DailyProgress(date: today, notesCompleted: completedToday, profile: profile)
            context.insert(progress)
        }
        try? context.save()
    }
}
