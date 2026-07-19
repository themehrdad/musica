import AudioKit
import AudioKitEX
import AVFoundation
import Foundation
import QuartzCore
import SoundpipeAudioKit

@MainActor
@Observable
final class AudioService {
    var detectedNote: MusicNote?
    var amplitude: Float = 0
    var isListening = false

    private var engine: AudioEngine?
    private var pitchTap: PitchTap?
    private var classifierTapNode: Fader?
    private var classifier: PianoSoundClassifier?
    private var gatekeeper = NoteGatekeeper()
    private var stableCount = 0
    private var lastMidi: Int?
    // Invalidates in-flight classification callbacks from a previous
    // engine/classifier after a quick mic toggle (stop → start).
    private var session = 0

    func start() throws {
        guard !isListening else { return }

        // Create a fresh engine each time to avoid stale state
        let newEngine = AudioEngine()
        guard let input = newEngine.input else { return }

        // Serial chain: mic -> tapNode (unity gain) -> silence (gain 0) -> output.
        // A node allows only one tap, so PitchTap taps the mic input while the
        // classifier taps tapNode. Never tap the gain-0 fader — taps capture a
        // node's output, which is zeros there.
        let tapNode = Fader(input)
        let silence = Fader(tapNode, gain: 0)
        newEngine.output = silence

        pitchTap = PitchTap(input) { [weak self] pitchArray, ampArray in
            self?.processPitch(pitchArray[0], amplitude: ampArray[0])
        }

        try newEngine.start()

        session += 1
        if Config.pianoGateEnabled {
            setUpClassifier(tapping: tapNode)
        }
        gatekeeper = NoteGatekeeper(bypassed: classifier == nil)
        if classifier == nil {
            GateLog.log("⚠️ GATE BYPASSED (classifier disabled or unavailable) — ALL pitched sounds will register")
        }
        GateLog.log("listening started, session=\(session)")

        pitchTap?.start()
        engine = newEngine
        isListening = true
    }

    func stop() {
        pitchTap?.stop()
        pitchTap = nil
        classifierTapNode?.avAudioNode.removeTap(onBus: 0)
        classifierTapNode = nil
        classifier = nil
        engine?.stop()
        engine = nil
        isListening = false
        detectedNote = nil
        stableCount = 0
        lastMidi = nil
        gatekeeper = NoteGatekeeper()
    }

    private func setUpClassifier(tapping node: Fader) {
        // The classifier must be recreated with each engine — the analyzer's
        // window state doesn't survive a restart. Reading the tap format is
        // only valid after the engine has started.
        let format = node.avAudioNode.outputFormat(forBus: 0)
        let newClassifier: PianoSoundClassifier
        let currentSession = session
        do {
            newClassifier = try PianoSoundClassifier(format: format) { [weak self] classification in
                Task { @MainActor in
                    self?.handleClassification(classification, session: currentSession)
                }
            }
        } catch {
            // Classifier unavailable: fall back to ungated pitch detection
            // (classifier stays nil) rather than an app that hears nothing.
            GateLog.log("classifier failed to start: \(error)")
            return
        }

        // Tap the fader directly rather than through an AudioKit tap:
        // AudioKit taps force every buffer to a fixed frame count, which
        // splices the stream the analyzer reassembles from sample positions.
        // analyze() only enqueues, so the render thread never waits on an
        // inference.
        // @Sendable keeps the closure nonisolated — it runs on the audio
        // render thread, and a MainActor-inferred closure would trap there.
        node.avAudioNode.installTap(onBus: 0, bufferSize: 8192, format: nil) { @Sendable buffer, time in
            newClassifier.analyze(buffer, at: time)
        }
        classifierTapNode = node
        classifier = newClassifier
    }

    private func handleClassification(_ classification: PianoClassification, session callbackSession: Int) {
        guard isListening, callbackSession == session else { return }
        let wasOpen = gatekeeper.isGateOpen(at: classification.time)
        let flushed = gatekeeper.classification(pianoConfidence: classification.pianoConfidence,
                                                voiceConfidence: classification.voiceConfidence,
                                                at: classification.time)
        let nowOpen = gatekeeper.isGateOpen(at: classification.time)
        if wasOpen != nowOpen {
            GateLog.log(nowOpen ? "gate OPENED" : "gate closed")
        }
        if let midi = flushed {
            GateLog.log("flush held note midi=\(midi) -> PUBLISH")
            if let note = MusicNote(midiNumber: midi) {
                detectedNote = note
            }
        }
    }

    private func processPitch(_ frequency: Float, amplitude amp: Float) {
        amplitude = amp

        guard amp > Config.pitchAmplitudeThreshold else {
            stableCount = 0
            lastMidi = nil
            detectedNote = nil
            return
        }

        guard frequency > 0 else { return }

        let midi = Int(round(69 + 12 * log2(Double(frequency) / 440.0)))

        if midi == lastMidi {
            stableCount += 1
        } else {
            stableCount = 1
            lastMidi = midi
        }

        guard stableCount >= Config.pitchStabilityFrames else { return }
        // Log only the frame where the note first becomes stable; it keeps
        // re-qualifying every ~90ms while it sustains.
        let isNewlyStable = stableCount == Config.pitchStabilityFrames
        let now = CACurrentMediaTime()

        // Sharps/flats have no MusicNote in this naturals-only app; ignore
        // them without evicting a held natural from the gatekeeper.
        guard let note = MusicNote(midiNumber: midi) else {
            if isNewlyStable {
                GateLog.log("stable midi=\(midi) -> ignored (sharp) | \(gatekeeper.stateDescription(at: now))")
            }
            return
        }

        if let accepted = gatekeeper.stableNote(midi: midi, at: now) {
            if isNewlyStable {
                GateLog.log("stable \(note.displayName) (midi \(accepted)) -> PUBLISH | \(gatekeeper.stateDescription(at: now))")
            }
            detectedNote = MusicNote(midiNumber: accepted)
        } else if isNewlyStable {
            GateLog.log("stable \(note.displayName) (midi \(midi)) -> HELD | \(gatekeeper.stateDescription(at: now))")
        }
    }
}
