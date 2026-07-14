import XCTest
@testable import Musica

final class PracticeDeckTests: XCTestCase {
    func testDefaultTrebleBeginnerDeckMatchesClassicRange() {
        let deck = PracticeDeck(beginner: true, clefMode: .treble)
        let expected = Config.trebleBeginnerRange.compactMap { MusicNote(midiNumber: $0) }.count
        XCTAssertEqual(deck.count, expected)
        for _ in 0..<20 {
            let card = deck.draw()
            XCTAssertEqual(card.staff, .treble)
            XCTAssertTrue(Config.trebleBeginnerRange.contains(card.note.midiNumber))
        }
    }

    func testDefaultBothBeginnerDeckCoversBothStaffs() {
        let deck = PracticeDeck(beginner: true, clefMode: .both)
        let trebleCount = Config.trebleBeginnerRange.compactMap { MusicNote(midiNumber: $0) }.count
        let bassCount = Config.bassBeginnerRange.compactMap { MusicNote(midiNumber: $0) }.count
        XCTAssertEqual(deck.count, trebleCount + bassCount)

        var sawTreble = false, sawBass = false
        for _ in 0..<60 {
            let card = deck.draw()
            switch card.staff {
            case .treble:
                sawTreble = true
                XCTAssertTrue(Config.trebleBeginnerRange.contains(card.note.midiNumber))
            case .bass:
                sawBass = true
                XCTAssertTrue(Config.bassBeginnerRange.contains(card.note.midiNumber))
            }
        }
        XCTAssertTrue(sawTreble && sawBass)
    }

    // The uncustomized grand-staff deck must split hands at middle C —
    // otherwise C3–B3 are dealt as treble cards that render inside the
    // bass staff and read as the wrong note.
    func testDefaultBothFullDeckSplitsHandsAtMiddleC() {
        let deck = PracticeDeck(beginner: false, clefMode: .both)
        for _ in 0..<60 {
            let card = deck.draw()
            if card.staff == .treble {
                XCTAssertGreaterThanOrEqual(card.note.midiNumber, 60)
            } else {
                XCTAssertLessThan(card.note.midiNumber, 60)
            }
        }
    }

    func testCustomKeysOverrideDefaults() {
        // parent picked three problem keys: C4, F4, B4
        let deck = PracticeDeck(beginner: true, clefMode: .treble, trebleKeys: [60, 65, 71])
        XCTAssertEqual(deck.count, 3)
        for _ in 0..<20 {
            XCTAssertTrue([60, 65, 71].contains(deck.draw().note.midiNumber))
        }
    }

    func testBothModeDealsEachHandItsOwnKeys() {
        // right hand drills A3 (below middle C!), left hand drills E4 (above its staff)
        let deck = PracticeDeck(beginner: false, clefMode: .both, trebleKeys: [57], bassKeys: [64])
        XCTAssertEqual(deck.count, 2)
        for _ in 0..<20 {
            let card = deck.draw()
            if card.note.midiNumber == 57 {
                XCTAssertEqual(card.staff, .treble, "right-hand A3 must render on the treble staff")
            } else {
                XCTAssertEqual(card.note.midiNumber, 64)
                XCTAssertEqual(card.staff, .bass, "left-hand E4 must render on the bass staff")
            }
        }
    }

    // Custom keys outside the grand-staff selector bounds (stale data from a
    // single-staff mode) are clamped, not rendered into the other staff.
    func testBothModeClampsCustomKeysOutsideGrandStaffBounds() {
        // C3 (48) is selectable in treble-only mode but not on the grand staff
        let deck = PracticeDeck(beginner: true, clefMode: .both, trebleKeys: [48, 60], bassKeys: [43])
        XCTAssertEqual(deck.count, 2)   // C4 + bass G2; C3 dropped
        for _ in 0..<20 {
            let card = deck.draw()
            XCTAssertNotEqual(card.note.midiNumber, 48)
        }
    }

    func testBothModeWithOnlyOneCustomHandFallsBackForOther() {
        let deck = PracticeDeck(beginner: true, clefMode: .both, trebleKeys: [60])
        let bassDefault = Config.bassBeginnerRange.compactMap { MusicNote(midiNumber: $0) }.count
        XCTAssertEqual(deck.count, 1 + bassDefault)
        for _ in 0..<30 {
            let card = deck.draw()
            if card.staff == .treble {
                XCTAssertEqual(card.note.midiNumber, 60)
            } else {
                XCTAssertTrue(Config.bassBeginnerRange.contains(card.note.midiNumber))
            }
        }
    }

    // A one-key hand competes fairly: hands alternate 50/50 regardless of
    // how many keys the other hand has.
    func testBothModeBalancesHandsRegardlessOfPoolSizes() {
        let deck = PracticeDeck(beginner: true, clefMode: .both, trebleKeys: [60])
        var trebleDraws = 0
        for _ in 0..<400 where deck.draw().staff == .treble {
            trebleDraws += 1
        }
        // ~200 expected; a generous band keeps the test deterministic enough
        XCTAssertTrue((120...280).contains(trebleDraws),
                      "one-key treble hand drew \(trebleDraws)/400 — expected roughly half")
    }

    func testDrawAvoidsImmediateRepeat() {
        let deck = PracticeDeck(beginner: true, clefMode: .treble, trebleKeys: [60, 62])
        var previous = deck.draw()
        for _ in 0..<30 {
            let next = deck.draw(avoiding: previous)
            XCTAssertNotEqual(next.note.midiNumber, previous.note.midiNumber)
            previous = next
        }
    }

    // The same pitch on the other staff is still a repeat of the same key.
    func testDrawAvoidsPreviousPitchAcrossStaves() {
        let deck = PracticeDeck(beginner: true, clefMode: .both, trebleKeys: [60], bassKeys: [60, 62])
        var previous = deck.draw()
        for _ in 0..<30 {
            let next = deck.draw(avoiding: previous)
            XCTAssertNotEqual(next.note.midiNumber, previous.note.midiNumber)
            previous = next
        }
    }

    func testSingleCardDeckAllowsRepeat() {
        let deck = PracticeDeck(beginner: true, clefMode: .treble, trebleKeys: [60])
        let first = deck.draw()
        let second = deck.draw(avoiding: first)
        XCTAssertEqual(second.note.midiNumber, 60)
    }

    // Same pitch chosen for both hands: repeating is the only option and
    // must not crash.
    func testSamePitchBothHandsDeckStillDraws() {
        let deck = PracticeDeck(beginner: true, clefMode: .both, trebleKeys: [60], bassKeys: [60])
        let first = deck.draw()
        let second = deck.draw(avoiding: first)
        XCTAssertEqual(second.note.midiNumber, 60)
    }

    func testSharpsAreDroppedFromCustomKeys() {
        // 61 = C#4 has no natural-note representation
        let deck = PracticeDeck(beginner: true, clefMode: .treble, trebleKeys: [60, 61])
        XCTAssertEqual(deck.count, 1)
    }

    func testEmptyDeckFallsBackInsteadOfCrashing() {
        // only sharps selected -> pool would be empty -> beginner fallback
        let deck = PracticeDeck(beginner: false, clefMode: .treble, trebleKeys: [61])
        XCTAssertGreaterThan(deck.count, 0)
        _ = deck.draw()
    }
}

final class ProfileKeySanitizingTests: XCTestCase {
    @MainActor
    func testProfileSanitizesKeys() {
        let profile = Profile(name: "Kid", trebleKeys: [65, 60, 60, 61], bassKeys: [43])
        XCTAssertEqual(profile.trebleKeys, [60, 65])   // deduped, sorted, sharp dropped
        XCTAssertEqual(profile.bassKeys, [43])
    }
}
