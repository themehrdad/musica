import XCTest
@testable import Musica

final class FreeTierTests: XCTestCase {

    // Debug's master switch can bypass gates; Release keeps them enabled.
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

    func testFreeLearnerCanCompleteDefaultGoal() {
        XCTAssertEqual(Config.freeDailyNoteLimit, 20)
        XCTAssertGreaterThanOrEqual(Config.freeDailyNoteLimit, Config.dailyGoal)
    }

    func testHigherGoalIsReachableAfterPremiumExpires() {
        XCTAssertEqual(FreeTier.practiceGoal(requested: 50, premium: false, gatingEnabled: true), 20)
        XCTAssertEqual(FreeTier.practiceGoal(requested: 50, premium: true, gatingEnabled: true), 50)
        XCTAssertEqual(FreeTier.practiceGoal(requested: 5, premium: false, gatingEnabled: true), 5)
        XCTAssertEqual(FreeTier.practiceGoal(requested: 50, premium: false, gatingEnabled: false), 50)
    }
}
