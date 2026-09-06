import XCTest
import SwiftData
@testable import Musica

final class RatingPrompterTests: XCTestCase {
    func testReviewRequestsAreSpacedAcrossSessions() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        XCTAssertTrue(RatingPrompter.mayRequest(lastRequested: nil, now: now))
        XCTAssertFalse(RatingPrompter.mayRequest(lastRequested: now, now: now))
        XCTAssertFalse(RatingPrompter.mayRequest(lastRequested: now.addingTimeInterval(60), now: now))
        XCTAssertFalse(RatingPrompter.mayRequest(lastRequested: now.addingTimeInterval(-86400), now: now))
        XCTAssertTrue(RatingPrompter.mayRequest(
            lastRequested: now.addingTimeInterval(-RatingPrompter.requestInterval), now: now))
    }

    @MainActor
    func testFreeSessionCelebratesBeforeLimitAndPersistsReachableGoal() throws {
        let context = try makeContext()
        let profile = try makeProfile(in: context, dailyGoal: 50)
        let vm = PracticeViewModel(profile: profile, gatingEnabled: true, premiumStatus: { false })
        vm.setup(context: context)
        XCTAssertEqual(vm.dailyGoal, 20)
        for _ in 0..<19 {
            vm.evaluateNote(vm.currentNote)
            vm.nextNote()
        }
        XCTAssertTrue(vm.canPracticeMore)
        vm.evaluateNote(vm.currentNote)
        XCTAssertEqual(vm.completedToday, 20)
        XCTAssertFalse(vm.canPracticeMore)
        XCTAssertFalse(vm.showFreeLimit, "The correct-answer feedback must remain visible")
        vm.state = .goalReached
        XCTAssertFalse(vm.showFreeLimit, "The daily crown must remain visible")
        XCTAssertEqual(RatingPrompter.goalDaysReached(profile: profile, context: context), 1)
        XCTAssertEqual(profile.dailyGoal, 50, "Retain the parent's Premium goal preference")
        vm.continueAfterGoal()
        XCTAssertTrue(vm.showFreeLimit)
        vm.evaluateNote(vm.currentNote)
        XCTAssertEqual(vm.completedToday, 20, "The twenty-first note must stay gated")

        let reopened = PracticeViewModel(profile: profile, gatingEnabled: true, premiumStatus: { false })
        reopened.setup(context: context)
        XCTAssertTrue(reopened.showFreeLimit, "Reopening cannot reset the allowance")
    }

    @MainActor
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Profile.self, DailyProgress.self,
                                           configurations: config)
        return ModelContext(container)
    }

    @MainActor
    private func makeProfile(in context: ModelContext, dailyGoal: Int = 20) throws -> Profile {
        let profile = Profile(name: "Testy", dailyGoal: dailyGoal)
        context.insert(profile)
        return profile
    }

    @MainActor
    private func recordDay(_ offset: Int, completed: Int, goal: Int,
                           profile: Profile, in context: ModelContext) throws {
        let day = Calendar.current.date(byAdding: .day, value: offset, to: .now)!
        let progress = DailyProgress(date: DailyProgress.dayString(from: day),
                                     notesCompleted: completed, goal: goal, profile: profile)
        context.insert(progress)
    }

    // MARK: - Counting goal days

    @MainActor
    func testEmptyHistoryCountsZero() throws {
        let context = try makeContext()
        let profile = try makeProfile(in: context)
        XCTAssertEqual(RatingPrompter.goalDaysReached(profile: profile, context: context), 0)
    }

    @MainActor
    func testDayBelowGoalDoesNotCount() throws {
        let context = try makeContext()
        let profile = try makeProfile(in: context)
        try recordDay(-1, completed: 19, goal: 20, profile: profile, in: context)
        XCTAssertEqual(RatingPrompter.goalDaysReached(profile: profile, context: context), 0)
    }

    @MainActor
    func testOvershootingCountsOneDay() throws {
        let context = try makeContext()
        let profile = try makeProfile(in: context)
        try recordDay(-1, completed: 27, goal: 20, profile: profile, in: context)
        XCTAssertEqual(RatingPrompter.goalDaysReached(profile: profile, context: context), 1)
    }

    // A day's star is judged against the goal that applied that day — the
    // rating ask follows the same rule.
    @MainActor
    func testUsesTheGoalStoredThatDay() throws {
        let context = try makeContext()
        let profile = try makeProfile(in: context)
        try recordDay(-1, completed: 20, goal: 20, profile: profile, in: context)
        try recordDay(-2, completed: 20, goal: 30, profile: profile, in: context)
        XCTAssertEqual(RatingPrompter.goalDaysReached(profile: profile, context: context), 1)
    }

    @MainActor
    func testProfilesCountSeparately() throws {
        let context = try makeContext()
        let sibling = try makeProfile(in: context)
        let profile = try makeProfile(in: context)
        try recordDay(-1, completed: 20, goal: 20, profile: sibling, in: context)
        XCTAssertEqual(RatingPrompter.goalDaysReached(profile: profile, context: context), 0)
    }

    // MARK: - The ask fires on the third goal day

    // Low goal keeps every note under the free daily limit, so nothing is
    // gated. Returns the view model that crossed the goal — the thing
    // PracticeView observes.
    @MainActor
    private func reachGoal(profile: Profile, in context: ModelContext) throws -> PracticeViewModel {
        let vm = PracticeViewModel(profile: profile)
        vm.setup(context: context)
        for _ in 0..<profile.dailyGoal {
            vm.evaluateNote(vm.currentNote)
            vm.nextNote()
        }
        return vm
    }

    @MainActor
    func testThirdGoalDayRequestsReview() throws {
        let context = try makeContext()
        let profile = try makeProfile(in: context, dailyGoal: 3)
        try recordDay(-1, completed: 3, goal: 3, profile: profile, in: context)
        try recordDay(-2, completed: 5, goal: 3, profile: profile, in: context)

        let vm = try reachGoal(profile: profile, in: context)

        XCTAssertEqual(vm.completedToday, 3)
        XCTAssertEqual(RatingPrompter.goalDaysReached(profile: profile, context: context), 3)
        XCTAssertTrue(vm.shouldRequestReview)
    }

    @MainActor
    func testSecondGoalDayDoesNotRequestReview() throws {
        let context = try makeContext()
        let profile = try makeProfile(in: context, dailyGoal: 3)
        try recordDay(-1, completed: 4, goal: 3, profile: profile, in: context)

        let vm = try reachGoal(profile: profile, in: context)

        XCTAssertEqual(vm.completedToday, 3)
        XCTAssertEqual(RatingPrompter.goalDaysReached(profile: profile, context: context), 2)
        XCTAssertFalse(vm.shouldRequestReview)
    }
}
