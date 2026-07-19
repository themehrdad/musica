import AVFoundation
import CoreMedia
import Foundation
import QuartzCore
import SoundAnalysis

/// A single classifier verdict about the most recent window of mic audio.
struct PianoClassification: Sendable {
    /// Highest confidence across the piano-family labels.
    let pianoConfidence: Double
    /// Highest confidence across speech and singing.
    let voiceConfidence: Double
    /// Monotonic host time (CACurrentMediaTime) when the result arrived.
    let time: TimeInterval
}

/// Runs Apple's on-device sound classifier over raw mic buffers and reports
/// how confident it is that a piano is currently sounding. Must be recreated
/// together with the audio engine — the analyzer's window state doesn't
/// survive an engine restart.
final class PianoSoundClassifier: @unchecked Sendable {
    /// Serial queue all analysis runs on; pass as RawBufferTap's callbackQueue.
    let analysisQueue = DispatchQueue(label: "com.musica.piano-classifier")

    private let analyzer: SNAudioStreamAnalyzer
    // The analyzer does not retain its observers; results stop silently
    // without this strong reference.
    private let observer: PianoResultsObserver

    init(format: AVAudioFormat, onResult: @escaping @Sendable (PianoClassification) -> Void) throws {
        let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
        request.windowDuration = CMTimeMakeWithSeconds(Config.classifierWindowSeconds,
                                                       preferredTimescale: 48_000)
        request.overlapFactor = Config.classifierOverlapFactor

        let known = request.knownClassifications
        var labels = Config.pianoLabels.filter { known.contains($0) }
        if labels.isEmpty {
            labels = Set(known.filter { $0.contains("piano") })
        }
        GateLog.log("classifier started: labels=\(labels.sorted()), format=\(Int(format.sampleRate))Hz \(format.channelCount)ch, window=\(Config.classifierWindowSeconds)s overlap=\(Config.classifierOverlapFactor)")

        observer = PianoResultsObserver(labels: labels, onResult: onResult)
        analyzer = SNAudioStreamAnalyzer(format: format)
        try analyzer.add(request, withObserver: observer)
    }

    /// Feed a mic buffer. Safe to call from the audio tap thread: the buffer
    /// is only enqueued here, so the caller never waits on an inference.
    func analyze(_ buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        // The tap hands the buffer off and never touches it again.
        nonisolated(unsafe) let buffer = buffer
        let position = time.sampleTime
        analysisQueue.async {
            self.analyzer.analyze(buffer, atAudioFramePosition: position)
        }
    }
}

private final class PianoResultsObserver: NSObject, SNResultsObserving, @unchecked Sendable {
    private let labels: Set<String>
    private let onResult: @Sendable (PianoClassification) -> Void

    init(labels: Set<String>, onResult: @escaping @Sendable (PianoClassification) -> Void) {
        self.labels = labels
        self.onResult = onResult
    }

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        let confidence = labels
            .compactMap { result.classification(forIdentifier: $0)?.confidence }
            .max() ?? 0
        let speech = result.classification(forIdentifier: "speech")?.confidence ?? 0
        let singing = result.classification(forIdentifier: "singing")?.confidence ?? 0
        // classifications are sorted by descending confidence
        let top = result.classifications.prefix(3)
            .map { String(format: "%@ %.2f", $0.identifier, $0.confidence) }
            .joined(separator: ", ")
        GateLog.log(String(format: "result piano=%.2f speech=%.2f singing=%.2f top=[%@]",
                           confidence, speech, singing, top))
        onResult(PianoClassification(pianoConfidence: confidence,
                                     voiceConfidence: max(speech, singing),
                                     time: CACurrentMediaTime()))
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        GateLog.log("classifier request FAILED: \(error)")
    }
}
