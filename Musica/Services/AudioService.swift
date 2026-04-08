import Foundation
import AudioKit
import AudioKitEX
import SoundpipeAudioKit

@MainActor
@Observable
final class AudioService {
    var detectedNote: MusicNote?
    var amplitude: Float = 0
    var isListening = false

    private var engine = AudioEngine()
    private var pitchTap: PitchTap?
    private var stableCount = 0
    private var lastMidi: Int?

    func start() throws {
        guard let input = engine.input else { return }

        // Route input through a silent fader so the engine has an output node
        let silence = Fader(input, gain: 0)
        engine.output = silence

        pitchTap = PitchTap(input) { [weak self] pitchArray, ampArray in
            // PitchTap already dispatches to DispatchQueue.main
            self?.processPitch(pitchArray[0], amplitude: ampArray[0])
        }

        try engine.start()
        pitchTap?.start()
        isListening = true
    }

    func stop() {
        pitchTap?.stop()
        engine.stop()
        isListening = false
        detectedNote = nil
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

        if stableCount >= Config.pitchStabilityFrames {
            detectedNote = MusicNote(midiNumber: midi)
        }
    }
}
