import XCTest
import SwiftData
@testable import Musica

final class DailyProgressTests: XCTestCase {

    private func makeProfile() -> Profile {
        Profile(name: "Testy")
    }

    // MARK: - Practiced-note storage

    func testPracticedNotesEmptyByDefault() {
        let progress = DailyProgress(date: "2026-07-17", profile: makeProfile())
        XCTAssertEqual(progress.practicedNotes, [])
        XCTAssertEqual(progress.practicedNotesRaw, "")
    }

    func testRecordNoteAppendsInOrder() {
        let progress = DailyProgress(date: "2026-07-17", profile: makeProfile())
        progress.recordNote("C4")
        progress.recordNote("E4")
        progress.recordNote("C4")
        XCTAssertEqual(progress.practicedNotes, ["C4", "E4", "C4"])
        XCTAssertEqual(progress.practicedNotesRaw, "C4,E4,C4")
    }

    func testPracticedNotesSetterRoundTrips() {
        let progress = DailyProgress(date: "2026-07-17", profile: makeProfile())
        progress.practicedNotes = ["D4", "F4", "A4"]
        XCTAssertEqual(progress.practicedNotesRaw, "D4,F4,A4")
        XCTAssertEqual(progress.practicedNotes, ["D4", "F4", "A4"])
    }

    func testDayStringMatchesTodayString() {
        XCTAssertEqual(DailyProgress.dayString(from: .now), DailyProgress.todayString())
    }

    // MARK: - Recording through the practice flow

    @MainActor
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Profile.self, DailyProgress.self,
                                           configurations: config)
        return ModelContext(container)
    }

    @MainActor
    func testCorrectAnswerRecordsScoreAndNote() throws {
        let context = try makeContext()
        let profile = makeProfile()
        context.insert(profile)

        let vm = PracticeViewModel(profile: profile)
        vm.setup(context: context)
        let target = vm.currentNote
        vm.evaluateNote(target)

        XCTAssertEqual(vm.completedToday, 1)
        let saved = try context.fetch(FetchDescriptor<DailyProgress>())
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.date, DailyProgress.todayString())
        XCTAssertEqual(saved.first?.notesCompleted, 1)
        XCTAssertEqual(saved.first?.practicedNotes, [target.displayName])
    }

    @MainActor
    func testWrongAnswerRecordsNothing() throws {
        let context = try makeContext()
        let profile = makeProfile()
        context.insert(profile)

        let vm = PracticeViewModel(profile: profile)
        vm.setup(context: context)
        let wrongMidi = vm.currentNote.midiNumber == 60 ? 62 : 60
        vm.evaluateNote(MusicNote(midiNumber: wrongMidi)!)

        XCTAssertEqual(vm.completedToday, 0)
        let saved = try context.fetch(FetchDescriptor<DailyProgress>())
        XCTAssertTrue(saved.isEmpty)
    }
}
