import Foundation

/// The freemium rules in one place: on the free plan a family gets one
/// profile, treble clef, and a few notes per day; Premium removes every
/// limit. All checks collapse to "allowed" while the master switch in
/// Config is off, so the gates can ship dark.
enum FreeTier {
    static func limited(premium: Bool,
                        gatingEnabled: Bool = Config.premiumGatingEnabled) -> Bool {
        gatingEnabled && !premium
    }

    static func canAddProfile(existingCount: Int, premium: Bool,
                              gatingEnabled: Bool = Config.premiumGatingEnabled) -> Bool {
        !limited(premium: premium, gatingEnabled: gatingEnabled)
            || existingCount < Config.freeProfileLimit
    }

    static func clefAllowed(_ clef: ClefMode, premium: Bool,
                            gatingEnabled: Bool = Config.premiumGatingEnabled) -> Bool {
        !limited(premium: premium, gatingEnabled: gatingEnabled) || clef == .treble
    }

    static func canPracticeMore(completedToday: Int, premium: Bool,
                                gatingEnabled: Bool = Config.premiumGatingEnabled) -> Bool {
        !limited(premium: premium, gatingEnabled: gatingEnabled)
            || completedToday < Config.freeDailyNoteLimit
    }
}
