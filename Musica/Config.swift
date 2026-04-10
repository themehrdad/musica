import Foundation

enum Config {
    static let dailyGoal = 20
    static let wrongAttemptsBeforeHint = 3
    static let pitchAmplitudeThreshold: Float = 0.05
    static let pitchStabilityFrames = 3
    static let trebleNoteRange: ClosedRange<Int> = 48...79          // MIDI C3–G5
    static let trebleBeginnerRange: ClosedRange<Int> = 64...77     // MIDI E4–F5 (on treble staff)
    static let bassNoteRange: ClosedRange<Int> = 36...59           // MIDI C2–B3
    static let bassBeginnerRange: ClosedRange<Int> = 43...57       // MIDI G2–A3 (on bass staff)
    static let naturalNotesOnly = true
}
