import XCTest
@testable import Musica

final class FreeTierTests: XCTestCase {

    // With the master switch off (today's shipping state) nothing is limited.
    func testGatingDisabledAllowsEverything() {
        XCTAssertFalse(FreeTier.limited(premium: false, gatingEnabled: false))
        XCTAssertTrue(FreeTier.canAddProfile(existingCount: 99, premium: false, gatingEnabled: false))
        XCTAssertTrue(FreeTier.clefAllowed(.both, premium: false, gatingEnabled: false))
        XCTAssertTrue(FreeTier.canPracticeMore(completedToday: 999, premium: false, gatingEnabled: false))
    }

    func testPremiumUnlimitedWhenGatingEnabled() {
        XCTAssertFalse(FreeTier.limited(premium: true, gatingEnabled: true))
        XCTAssertTrue(FreeTier.canAddProfile(existingCount: 99, premium: true, gatingEnabled: true))
        XCTAssertTrue(FreeTier.clefAllowed(.bass, premium: true, gatingEnabled: true))
        XCTAssertTrue(FreeTier.canPracticeMore(completedToday: 999, premium: true, gatingEnabled: true))
    }

    func testFreePlanLimitsWhenGatingEnabled() {
        XCTAssertTrue(FreeTier.limited(premium: false, gatingEnabled: true))

        XCTAssertTrue(FreeTier.canAddProfile(existingCount: 0, premium: false, gatingEnabled: true))
        XCTAssertFalse(FreeTier.canAddProfile(existingCount: Config.freeProfileLimit,
                                              premium: false, gatingEnabled: true))

        XCTAssertTrue(FreeTier.clefAllowed(.treble, premium: false, gatingEnabled: true))
        XCTAssertFalse(FreeTier.clefAllowed(.bass, premium: false, gatingEnabled: true))
        XCTAssertFalse(FreeTier.clefAllowed(.both, premium: false, gatingEnabled: true))

        XCTAssertTrue(FreeTier.canPracticeMore(completedToday: Config.freeDailyNoteLimit - 1,
                                               premium: false, gatingEnabled: true))
        XCTAssertFalse(FreeTier.canPracticeMore(completedToday: Config.freeDailyNoteLimit,
                                                premium: false, gatingEnabled: true))
    }

    // Free-tier caps must stay below the default daily goal so the crown
    // celebration can't fire for capped users mid-session.
    func testFreeLimitBelowDailyGoal() {
        XCTAssertLessThan(Config.freeDailyNoteLimit, Config.dailyGoal)
    }
}
