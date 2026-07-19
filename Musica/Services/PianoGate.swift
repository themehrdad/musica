import Foundation

/// Hysteresis gate driven by sound-classifier confidence.
///
/// Opens after `hitsToOpen` consecutive results at or above `openConfidence`,
/// stays open while results keep arriving at or above `stayOpenConfidence`,
/// and closes once `stickySeconds` pass without a confident result. Closing is
/// pull-based — `isOpen(at:)` compares elapsed time — so a stalled classifier
/// can never wedge the gate open.
struct PianoGate {
    private let openConfidence: Double
    private let stayOpenConfidence: Double
    private let hitsToOpen: Int
    private let stickySeconds: TimeInterval

    private var consecutiveHits = 0
    private var lastConfidentAt: TimeInterval?

    init(openConfidence: Double = Config.gateOpenConfidence,
         stayOpenConfidence: Double = Config.gateStayOpenConfidence,
         hitsToOpen: Int = Config.gateHitsToOpen,
         stickySeconds: TimeInterval = Config.gateStickySeconds) {
        self.openConfidence = openConfidence
        self.stayOpenConfidence = stayOpenConfidence
        self.hitsToOpen = hitsToOpen
        self.stickySeconds = stickySeconds
    }

    func isOpen(at time: TimeInterval) -> Bool {
        guard let last = lastConfidentAt else { return false }
        return time - last <= stickySeconds
    }

    mutating func process(confidence: Double, at time: TimeInterval) {
        if isOpen(at: time) {
            consecutiveHits = 0
            if confidence >= stayOpenConfidence {
                lastConfidentAt = time
            }
        } else if confidence >= openConfidence {
            consecutiveHits += 1
            if consecutiveHits >= hitsToOpen {
                lastConfidentAt = time
                consecutiveHits = 0
            }
        } else {
            consecutiveHits = 0
        }
    }
}

/// Combines the classifier-driven ``PianoGate`` with a short pending-note
/// buffer: a stable pitch heard while the gate is closed is held until the
/// classifier confirms the sound is a piano, then published — or dropped if
/// confirmation arrives more than `pendingMaxAge` late. This keeps the first
/// note after silence from being lost to classifier latency while still
/// rejecting voice, whistling, and other pitched sounds.
///
/// A voice veto covers the gate's blind spot: the classifier judges the whole
/// acoustic scene, so while a piano note rings, a hummed or spoken pitch
/// would otherwise pass. When a result shows voice high and piano low, notes
/// are held back for a short stretch instead of published.
struct NoteGatekeeper {
    private var gate: PianoGate
    private let pendingMaxAge: TimeInterval
    private let bypassed: Bool
    private let voiceVetoConfidence: Double
    private let voiceVetoPianoCeiling: Double
    private let voiceVetoSeconds: TimeInterval

    private var pending: (midi: Int, time: TimeInterval)?
    private var voiceVetoUntil: TimeInterval = -.infinity

    /// - Parameter bypassed: when true (classifier disabled or unavailable),
    ///   every stable note passes through untouched — the original behavior.
    init(gate: PianoGate = PianoGate(),
         pendingMaxAge: TimeInterval = Config.pendingNoteMaxAge,
         bypassed: Bool = false,
         voiceVetoConfidence: Double = Config.voiceVetoConfidence,
         voiceVetoPianoCeiling: Double = Config.voiceVetoPianoCeiling,
         voiceVetoSeconds: TimeInterval = Config.voiceVetoSeconds) {
        self.gate = gate
        self.pendingMaxAge = pendingMaxAge
        self.bypassed = bypassed
        self.voiceVetoConfidence = voiceVetoConfidence
        self.voiceVetoPianoCeiling = voiceVetoPianoCeiling
        self.voiceVetoSeconds = voiceVetoSeconds
    }

    /// A pitch has been stable long enough to count as a note.
    /// Returns the midi number to publish now, or nil to hold it.
    mutating func stableNote(midi: Int, at time: TimeInterval) -> Int? {
        if bypassed { return midi }
        if gate.isOpen(at: time), time >= voiceVetoUntil {
            pending = nil
            return midi
        }
        pending = (midi, time)
        return nil
    }

    /// A classifier result arrived. Returns a held midi number to publish
    /// if the gate opened soon enough after the note was heard.
    mutating func classification(pianoConfidence: Double,
                                 voiceConfidence: Double,
                                 at time: TimeInterval) -> Int? {
        gate.process(confidence: pianoConfidence, at: time)
        if voiceConfidence >= voiceVetoConfidence, pianoConfidence < voiceVetoPianoCeiling {
            voiceVetoUntil = time + voiceVetoSeconds
        }
        guard gate.isOpen(at: time), time >= voiceVetoUntil, let held = pending else { return nil }
        pending = nil
        return time - held.time <= pendingMaxAge ? held.midi : nil
    }

    func isGateOpen(at time: TimeInterval) -> Bool {
        !bypassed && gate.isOpen(at: time)
    }

    /// One-line state summary for diagnostics.
    func stateDescription(at time: TimeInterval) -> String {
        if bypassed { return "gate=BYPASSED" }
        var parts = ["gate=" + (gate.isOpen(at: time) ? "open" : "closed")]
        if time < voiceVetoUntil {
            parts.append(String(format: "veto=%.2fs", voiceVetoUntil - time))
        }
        if let pending {
            parts.append(String(format: "pending=midi%d(%.2fs old)", pending.midi, time - pending.time))
        }
        return parts.joined(separator: " ")
    }
}
