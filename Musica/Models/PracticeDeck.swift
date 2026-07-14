import Foundation

/// Which staff of the grand staff a card belongs to. A note practices the
/// hand it was dealt for, so a right-hand A3 renders on the treble staff
/// (with ledger lines) rather than hopping to the bass staff.
enum StaffSide {
    case treble
    case bass
}

/// One flash card: the note to play and the staff it is shown on.
struct PracticeCard: Equatable {
    let note: MusicNote
    let staff: StaffSide
}

/// The pool of practice cards for a profile — like a deck of memory cards
/// parents assemble from the keys their child needs to drill. Each hand has
/// its own pool; a hand without custom keys falls back to the classic
/// beginner/full staff range.
struct PracticeDeck {
    private let trebleCards: [PracticeCard]
    private let bassCards: [PracticeCard]

    init(profile: Profile) {
        self.init(beginner: profile.beginner, clefMode: profile.clefMode,
                  trebleKeys: profile.trebleKeys, bassKeys: profile.bassKeys)
    }

    init(beginner: Bool, clefMode: ClefMode, trebleKeys: [Int] = [], bassKeys: [Int] = []) {
        var treble: [PracticeCard] = []
        var bass: [PracticeCard] = []

        if clefMode == .treble || clefMode == .both {
            var fallback = beginner ? Config.trebleBeginnerRange : Config.trebleNoteRange
            // On the grand staff, uncustomized hands split at middle C (the
            // classic reading), and custom keys are clamped to the range the
            // selector showed — deeper notes would sit inside the bass staff.
            if clefMode == .both {
                fallback = max(60, fallback.lowerBound)...fallback.upperBound
            }
            treble = Self.pool(custom: trebleKeys, fallback: fallback,
                               clampTo: clefMode == .both ? Config.bothTrebleSelectableRange : nil)
                .map { PracticeCard(note: $0, staff: .treble) }
        }
        if clefMode == .bass || clefMode == .both {
            var fallback = beginner ? Config.bassBeginnerRange : Config.bassNoteRange
            if clefMode == .both {
                fallback = fallback.lowerBound...min(59, fallback.upperBound)
            }
            bass = Self.pool(custom: bassKeys, fallback: fallback,
                             clampTo: clefMode == .both ? Config.bothBassSelectableRange : nil)
                .map { PracticeCard(note: $0, staff: .bass) }
        }

        // A deck can never be empty: an impossible combination falls back to
        // the beginner treble range rather than a crash.
        if treble.isEmpty && bass.isEmpty {
            treble = Self.pool(custom: [], fallback: Config.trebleBeginnerRange, clampTo: nil)
                .map { PracticeCard(note: $0, staff: .treble) }
        }
        self.trebleCards = treble
        self.bassCards = bass
    }

    var count: Int { trebleCards.count + bassCards.count }

    /// Deal the next card. Hands take turns fairly (50/50 when both have
    /// cards, regardless of pool sizes), and the previous card's pitch is
    /// avoided whenever any other pitch exists.
    func draw(avoiding previous: PracticeCard? = nil) -> PracticeCard {
        let previousMidi = previous?.note.midiNumber
        let freshTreble = trebleCards.filter { $0.note.midiNumber != previousMidi }
        let freshBass = bassCards.filter { $0.note.midiNumber != previousMidi }

        let pool: [PracticeCard]
        switch (freshTreble.isEmpty, freshBass.isEmpty) {
        case (false, false): pool = Bool.random() ? freshTreble : freshBass
        case (false, true): pool = freshTreble
        case (true, false): pool = freshBass
        case (true, true):
            // Every card shares the previous pitch (e.g. a one-key deck) —
            // repeating is the only option.
            pool = trebleCards.isEmpty ? bassCards
                 : bassCards.isEmpty ? trebleCards
                 : (Bool.random() ? trebleCards : bassCards)
        }
        return pool.randomElement()!
    }

    private static func pool(custom: [Int], fallback: ClosedRange<Int>,
                             clampTo bounds: ClosedRange<Int>?) -> [MusicNote] {
        var keys = custom
        if let bounds {
            keys = keys.filter { bounds.contains($0) }
        }
        let midis = keys.isEmpty ? Array(fallback) : keys
        return midis.compactMap { MusicNote(midiNumber: $0) }
    }
}
