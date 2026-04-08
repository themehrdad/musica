import Foundation

enum NoteName: String, CaseIterable {
    case C, D, E, F, G, A, B
}

struct MusicNote: Equatable {
    let name: NoteName
    let octave: Int
    let midiNumber: Int

    private static let semitoneOffset: [NoteName: Int] = [
        .C: 0, .D: 2, .E: 4, .F: 5, .G: 7, .A: 9, .B: 11
    ]

    init(name: NoteName, octave: Int) {
        self.name = name
        self.octave = octave
        self.midiNumber = (octave + 1) * 12 + Self.semitoneOffset[name]!
    }

    init?(midiNumber: Int) {
        self.midiNumber = midiNumber
        let octave = midiNumber / 12 - 1
        let semitone = midiNumber % 12
        guard let match = Self.semitoneOffset.first(where: { $0.value == semitone }) else {
            return nil
        }
        self.name = match.key
        self.octave = octave
    }

    var frequency: Double {
        440.0 * pow(2.0, Double(midiNumber - 69) / 12.0)
    }

    static func fromFrequency(_ freq: Double) -> MusicNote? {
        let midi = 69 + 12 * log2(freq / 440.0)
        let rounded = Int(round(midi))
        guard Config.noteRange.contains(rounded) else { return nil }
        return MusicNote(midiNumber: rounded)
    }

    var staffPosition: Int {
        let noteOrder: [NoteName] = [.C, .D, .E, .F, .G, .A, .B]
        let index = noteOrder.firstIndex(of: name)!
        return (octave - 4) * 7 + index
    }

    static func random() -> MusicNote {
        let allNotes = (Config.noteRange).compactMap { MusicNote(midiNumber: $0) }
        return allNotes.randomElement()!
    }

    var displayName: String {
        "\(name.rawValue)\(octave)"
    }
}
