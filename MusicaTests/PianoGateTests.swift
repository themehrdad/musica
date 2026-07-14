import XCTest
@testable import Musica

final class PianoGateTests: XCTestCase {
    // openConfidence 0.5, stayOpenConfidence 0.25, hitsToOpen 2, sticky 4.0
    private func makeGate() -> PianoGate {
        PianoGate(openConfidence: 0.5, stayOpenConfidence: 0.25,
                  hitsToOpen: 2, stickySeconds: 4.0)
    }

    func testClosedInitially() {
        let gate = makeGate()
        XCTAssertFalse(gate.isOpen(at: 0))
    }

    func testSingleConfidentHitDoesNotOpen() {
        var gate = makeGate()
        gate.process(confidence: 0.9, at: 0)
        XCTAssertFalse(gate.isOpen(at: 0))
    }

    func testTwoConsecutiveHitsOpen() {
        var gate = makeGate()
        gate.process(confidence: 0.6, at: 0)
        gate.process(confidence: 0.6, at: 0.25)
        XCTAssertTrue(gate.isOpen(at: 0.25))
    }

    func testMissResetsConsecutiveCounter() {
        var gate = makeGate()
        gate.process(confidence: 0.6, at: 0)
        gate.process(confidence: 0.2, at: 0.25)
        gate.process(confidence: 0.6, at: 0.5)
        XCTAssertFalse(gate.isOpen(at: 0.5))
        gate.process(confidence: 0.6, at: 0.75)
        XCTAssertTrue(gate.isOpen(at: 0.75))
    }

    func testWeakResultsKeepGateOpen() {
        var gate = makeGate()
        gate.process(confidence: 0.6, at: 0)
        gate.process(confidence: 0.6, at: 0.25)
        // 0.3 >= stayOpen threshold: refreshes the sticky window
        gate.process(confidence: 0.3, at: 3.0)
        gate.process(confidence: 0.3, at: 6.0)
        XCTAssertTrue(gate.isOpen(at: 9.0))
    }

    func testGateClosesAfterStickyExpires() {
        var gate = makeGate()
        gate.process(confidence: 0.6, at: 0)
        gate.process(confidence: 0.6, at: 0.25)
        // very weak results do not refresh
        gate.process(confidence: 0.1, at: 2.0)
        XCTAssertTrue(gate.isOpen(at: 4.25))
        XCTAssertFalse(gate.isOpen(at: 4.26))
    }

    func testReopenAfterExpiryNeedsConsecutiveHitsAgain() {
        var gate = makeGate()
        gate.process(confidence: 0.6, at: 0)
        gate.process(confidence: 0.6, at: 0.25)
        XCTAssertTrue(gate.isOpen(at: 0.25))
        // long silence, gate expires
        XCTAssertFalse(gate.isOpen(at: 10))
        // one confident hit is not enough to reopen
        gate.process(confidence: 0.9, at: 10)
        XCTAssertFalse(gate.isOpen(at: 10))
        gate.process(confidence: 0.9, at: 10.25)
        XCTAssertTrue(gate.isOpen(at: 10.25))
    }

    func testExactThresholdCountsAsHit() {
        var gate = makeGate()
        gate.process(confidence: 0.5, at: 0)
        gate.process(confidence: 0.5, at: 0.25)
        XCTAssertTrue(gate.isOpen(at: 0.25))
        gate.process(confidence: 0.25, at: 4.0)
        XCTAssertTrue(gate.isOpen(at: 8.0))
    }
}

final class NoteGatekeeperTests: XCTestCase {
    // veto: voice >= 0.6 while piano < 0.3 blocks notes for 0.75s
    private func makeGatekeeper(pendingMaxAge: TimeInterval = 2.0,
                                bypassed: Bool = false) -> NoteGatekeeper {
        NoteGatekeeper(gate: PianoGate(openConfidence: 0.5, stayOpenConfidence: 0.25,
                                       hitsToOpen: 2, stickySeconds: 4.0),
                       pendingMaxAge: pendingMaxAge,
                       bypassed: bypassed,
                       voiceVetoConfidence: 0.6,
                       voiceVetoPianoCeiling: 0.3,
                       voiceVetoSeconds: 0.75)
    }

    private func openGate(_ keeper: inout NoteGatekeeper, at time: TimeInterval = 0) {
        _ = keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: time)
        _ = keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: time + 0.25)
    }

    func testStableNoteHeldWhileGateClosed() {
        var keeper = makeGatekeeper()
        XCTAssertNil(keeper.stableNote(midi: 60, at: 0.3))
    }

    func testPendingFlushedWhenGateOpens() {
        var keeper = makeGatekeeper()
        XCTAssertNil(keeper.stableNote(midi: 60, at: 0.3))
        XCTAssertNil(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.0))
        XCTAssertEqual(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.25), 60)
    }

    func testPendingFlushedOnlyOnce() {
        var keeper = makeGatekeeper()
        XCTAssertNil(keeper.stableNote(midi: 60, at: 0.3))
        XCTAssertNil(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.0))
        XCTAssertEqual(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.25), 60)
        XCTAssertNil(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.5))
    }

    func testStalePendingDropped() {
        var keeper = makeGatekeeper()
        XCTAssertNil(keeper.stableNote(midi: 60, at: 0))
        // gate opens too late — held note is stale and must not publish
        XCTAssertNil(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 2.5))
        XCTAssertNil(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 2.75))
    }

    func testNewerStableNoteOverwritesPending() {
        var keeper = makeGatekeeper()
        XCTAssertNil(keeper.stableNote(midi: 60, at: 0.3))
        XCTAssertNil(keeper.stableNote(midi: 64, at: 0.6))
        XCTAssertNil(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.0))
        XCTAssertEqual(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.25), 64)
    }

    func testNotePassesImmediatelyWhileGateOpen() {
        var keeper = makeGatekeeper()
        openGate(&keeper)
        XCTAssertEqual(keeper.stableNote(midi: 72, at: 1.0), 72)
        // consecutive notes while the gate stays open pass through instantly
        XCTAssertEqual(keeper.stableNote(midi: 74, at: 2.0), 74)
    }

    func testNoteBlockedAgainAfterGateExpires() {
        var keeper = makeGatekeeper()
        openGate(&keeper)
        XCTAssertEqual(keeper.stableNote(midi: 72, at: 1.0), 72)
        // sticky window (4s after last confident result) has passed
        XCTAssertNil(keeper.stableNote(midi: 74, at: 10.0))
    }

    // A short staccato note can fall silent before the classifier confirms;
    // the pending note must survive that gap and still flush.
    func testPendingSurvivesSilenceBeforeGateOpens() {
        var keeper = makeGatekeeper()
        XCTAssertNil(keeper.stableNote(midi: 60, at: 0.3))
        // (sound decayed below the amplitude threshold here)
        XCTAssertNil(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.0))
        XCTAssertEqual(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.25), 60)
    }

    func testBypassedPassesNotesStraightThrough() {
        var keeper = makeGatekeeper(bypassed: true)
        // no classifier results at all — notes must not be held
        XCTAssertEqual(keeper.stableNote(midi: 60, at: 0.3), 60)
        XCTAssertEqual(keeper.stableNote(midi: 62, at: 10.0), 62)
    }

    func testVoiceVetoBlocksNoteWhileGateOpen() {
        var keeper = makeGatekeeper()
        openGate(&keeper)
        // voice dominates the scene while the piano's decay keeps the gate open
        _ = keeper.classification(pianoConfidence: 0.1, voiceConfidence: 0.8, at: 0.5)
        XCTAssertNil(keeper.stableNote(midi: 60, at: 0.6))
    }

    func testVoiceVetoExpiresAndHeldNoteFlushes() {
        var keeper = makeGatekeeper()
        openGate(&keeper)
        _ = keeper.classification(pianoConfidence: 0.1, voiceConfidence: 0.8, at: 0.5)
        XCTAssertNil(keeper.stableNote(midi: 60, at: 0.6))
        // veto (until 1.25) still covers this result
        XCTAssertNil(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.0))
        // veto expired, held note is fresh (0.9s old) — flush it
        XCTAssertEqual(keeper.classification(pianoConfidence: 0.6, voiceConfidence: 0, at: 1.5), 60)
    }

    func testVoiceAlongsidePianoDoesNotVeto() {
        var keeper = makeGatekeeper()
        openGate(&keeper)
        // someone talks while the piano is clearly playing — don't block the player
        _ = keeper.classification(pianoConfidence: 0.5, voiceConfidence: 0.9, at: 0.5)
        XCTAssertEqual(keeper.stableNote(midi: 72, at: 0.6), 72)
    }

    func testContinuedVoiceKeepsVetoAlive() {
        var keeper = makeGatekeeper()
        openGate(&keeper)
        _ = keeper.classification(pianoConfidence: 0.1, voiceConfidence: 0.8, at: 0.5)
        _ = keeper.classification(pianoConfidence: 0.1, voiceConfidence: 0.8, at: 0.75)
        _ = keeper.classification(pianoConfidence: 0.1, voiceConfidence: 0.8, at: 1.0)
        // veto refreshed to 1.75; note at 1.5 still blocked
        XCTAssertNil(keeper.stableNote(midi: 60, at: 1.5))
    }
}
