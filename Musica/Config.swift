import Foundation

enum Config {
    static let dailyGoal = 20
    static let wrongAttemptsBeforeHint = 3
    static let pitchAmplitudeThreshold: Float = 0.05
    static let pitchStabilityFrames = 3
    static let noteRange: ClosedRange<Int> = 48...79          // MIDI C3–G5
    static let beginnerNoteRange: ClosedRange<Int> = 64...77  // MIDI E4–F5 (on staff, no ledger lines)
    static let naturalNotesOnly = true
}
