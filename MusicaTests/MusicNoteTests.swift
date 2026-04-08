import XCTest
@testable import Musica

final class MusicNoteTests: XCTestCase {
    func testMiddleCProperties() {
        let c4 = MusicNote(name: .C, octave: 4)
        XCTAssertEqual(c4.midiNumber, 60)
        XCTAssertEqual(c4.staffPosition, 0)
        XCTAssertEqual(c4.displayName, "C4")
        XCTAssertEqual(c4.frequency, 261.63, accuracy: 0.5)
    }

    func testA4Is440() {
        let a4 = MusicNote(name: .A, octave: 4)
        XCTAssertEqual(a4.midiNumber, 69)
        XCTAssertEqual(a4.frequency, 440.0, accuracy: 0.01)
    }

    func testFromFrequency() {
        let note = MusicNote.fromFrequency(440.0)
        XCTAssertEqual(note?.name, .A)
        XCTAssertEqual(note?.octave, 4)
    }

    func testMidiRoundTrip() {
        let original = MusicNote(name: .G, octave: 5)
        let fromMidi = MusicNote(midiNumber: original.midiNumber)
        XCTAssertEqual(fromMidi, original)
    }

    func testRandomInRange() {
        for _ in 0..<50 {
            let note = MusicNote.random()
            XCTAssertTrue(Config.noteRange.contains(note.midiNumber))
        }
    }

    func testStaffPositions() {
        // E4 should be on bottom line (position 2)
        let e4 = MusicNote(name: .E, octave: 4)
        XCTAssertEqual(e4.staffPosition, 2)

        // B4 should be on middle line (position 6)
        let b4 = MusicNote(name: .B, octave: 4)
        XCTAssertEqual(b4.staffPosition, 6)

        // F5 should be on top line (position 10)
        let f5 = MusicNote(name: .F, octave: 5)
        XCTAssertEqual(f5.staffPosition, 10)
    }

    func testSharpFlatReturnsNil() {
        // MIDI 61 = C#4, should return nil for natural-only
        let sharpNote = MusicNote(midiNumber: 61)
        XCTAssertNil(sharpNote)
    }
}
