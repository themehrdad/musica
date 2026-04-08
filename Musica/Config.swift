import Foundation

enum Config {
    static let dailyGoal = 20
    static let wrongAttemptsBeforeHint = 3
    static let pitchAmplitudeThreshold: Float = 0.05
    static let pitchStabilityFrames = 3
    static let noteRange: ClosedRange<Int> = 48...79  // MIDI C3–G5
    static let naturalNotesOnly = true
}
