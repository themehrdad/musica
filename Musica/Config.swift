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
    // Bounds of the per-hand key selector keyboards. Wide on purpose —
    // each hand can practice far beyond its staff — but capped where the
    // resulting ledger lines would become unreadable for a child.
    static let trebleSelectableRange: ClosedRange<Int> = 48...96   // MIDI C3–C7
    static let bassSelectableRange: ClosedRange<Int> = 36...72     // MIDI C2–C5

    // Tighter bounds when both staves are shown: a note deeper than these
    // would render inside the OTHER staff and read as the wrong note.
    static let bothTrebleSelectableRange: ClosedRange<Int> = 52...96   // MIDI E3–C7
    static let bothBassSelectableRange: ClosedRange<Int> = 36...69     // MIDI C2–A4

    // Piano-only gate: notes register only while Apple's on-device sound
    // classifier hears a piano. Confidence thresholds are tuned for this
    // window duration — retune them if it changes.
    static let pianoGateEnabled = true
    static let pianoLabels: Set<String> = ["piano", "electric_piano", "keyboard_musical"]
    static let classifierWindowSeconds = 1.0
    static let classifierOverlapFactor = 0.75                      // result every 0.25 s
    static let gateOpenConfidence = 0.5
    static let gateStayOpenConfidence = 0.25
    static let gateHitsToOpen = 2                                  // consecutive confident results to open
    static let gateStickySeconds: TimeInterval = 4.0               // stays open this long after last confident result
    static let pendingNoteMaxAge: TimeInterval = 2.0               // held note expires if classifier confirms later than this
    static let voiceVetoConfidence = 0.6                           // speech/singing at or above this...
    static let voiceVetoPianoCeiling = 0.3                         // ...while piano below this blocks notes...
    static let voiceVetoSeconds: TimeInterval = 0.75               // ...for this long after the result
}
