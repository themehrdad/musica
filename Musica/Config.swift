import Foundation

enum Config {
    // MARK: Premium subscription
    // Master switch for the freemium gates. OFF until the App Store products
    // are live — with it off the whole app behaves exactly as before, so
    // family devices lose nothing when this build ships.
    static let premiumGatingEnabled = false
    static let monthlyProductID = "com.musica.app.premium.monthly"
    static let yearlyProductID = "com.musica.app.premium.yearly"
    static let premiumProductIDs = [monthlyProductID, yearlyProductID]
    static let freeProfileLimit = 1
    static let freeDailyNoteLimit = 5
    static let privacyPolicyURL = URL(string: "https://themehrdad.github.io/musica/privacy.html")!
    static let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    static let dailyGoal = 20
    static let wrongAttemptsBeforeHint = 3
    static let pitchAmplitudeThreshold: Float = 0.05
    // 2 frames (~190 ms at the 93 ms tap cadence): fast enough that a quick
    // run registers quickly, stable enough to reject transient crackles.
    static let pitchStabilityFrames = 2
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
    // Short window opens the gate faster on the first note after silence:
    // first verdict lands at ~0.5 s instead of ~1.0 s.
    static let classifierWindowSeconds = 0.5
    static let classifierOverlapFactor = 0.5                       // result every 0.25 s
    static let gateOpenConfidence = 0.5
    static let gateStayOpenConfidence = 0.25
    static let gateHitsToOpen = 1                                  // one confident result opens the gate
    static let gateStickySeconds: TimeInterval = 2.0               // stays open this long after last confident result
    static let pendingNoteMaxAge: TimeInterval = 1.5               // held note expires if classifier confirms later than this
    static let voiceVetoConfidence = 0.6                           // speech/singing at or above this...
    static let voiceVetoPianoCeiling = 0.3                         // ...while piano below this blocks notes...
    static let voiceVetoSeconds: TimeInterval = 0.75               // ...for this long after the result
}
