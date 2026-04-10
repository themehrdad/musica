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

    private var engine: AudioEngine?
    private var pitchTap: PitchTap?
    private var stableCount = 0
    private var lastMidi: Int?

    func start() throws {
        // Create a fresh engine each time to avoid stale state
        let newEngine = AudioEngine()
        guard let input = newEngine.input else { return }

        let silence = Fader(input, gain: 0)
        newEngine.output = silence

        pitchTap = PitchTap(input) { [weak self] pitchArray, ampArray in
            self?.processPitch(pitchArray[0], amplitude: ampArray[0])
        }

        try newEngine.start()
        pitchTap?.start()
        engine = newEngine
        isListening = true
    }

    func stop() {
        pitchTap?.stop()
        pitchTap = nil
        engine?.stop()
        engine = nil
        isListening = false
        detectedNote = nil
        stableCount = 0
        lastMidi = nil
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
