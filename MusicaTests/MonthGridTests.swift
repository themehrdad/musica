import XCTest
@testable import Musica

final class MonthGridTests: XCTestCase {

    private func fixedCalendar(firstWeekday: Int = 1) -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        cal.locale = Locale(identifier: "en_US")
        cal.firstWeekday = firstWeekday
        return cal
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, in cal: Calendar) -> Date {
        cal.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func testAnchorNormalizesToMonthStart() {
        let cal = fixedCalendar()
        let grid = MonthGrid(containing: date(2026, 7, 17, in: cal), calendar: cal)
        XCTAssertEqual(grid.monthStart, date(2026, 7, 1, in: cal))
    }

    // July 2026 starts on a Wednesday: 3 leading blanks with a Sunday-first
    // week, 31 days, padded to 5 full weeks.
    func testJuly2026SundayFirstLayout() {
        let cal = fixedCalendar(firstWeekday: 1)
        let grid = MonthGrid(containing: date(2026, 7, 17, in: cal), calendar: cal)
        let cells = grid.cells

        XCTAssertEqual(cells.count, 35)
        XCTAssertTrue(cells[0..<3].allSatisfy { $0 == nil })
        XCTAssertEqual(cells[3], date(2026, 7, 1, in: cal))
        XCTAssertEqual(cells[33], date(2026, 7, 31, in: cal))
        XCTAssertNil(cells[34])
    }

    // February 2026 starts on a Sunday and has exactly 28 days: no blanks.
    func testFebruary2026FitsExactWeeks() {
        let cal = fixedCalendar(firstWeekday: 1)
        let grid = MonthGrid(containing: date(2026, 2, 10, in: cal), calendar: cal)
        let cells = grid.cells

        XCTAssertEqual(cells.count, 28)
        XCTAssertTrue(cells.allSatisfy { $0 != nil })
        XCTAssertEqual(cells.first ?? nil, date(2026, 2, 1, in: cal))
        XCTAssertEqual(cells.last ?? nil, date(2026, 2, 28, in: cal))
    }

    func testMondayFirstWeekdayShiftsBlanksAndSymbols() {
        let cal = fixedCalendar(firstWeekday: 2)
        let grid = MonthGrid(containing: date(2026, 7, 1, in: cal), calendar: cal)

        XCTAssertEqual(grid.cells.count, 35)
        XCTAssertTrue(grid.cells[0..<2].allSatisfy { $0 == nil })
        XCTAssertEqual(grid.cells[2], date(2026, 7, 1, in: cal))
        XCTAssertEqual(grid.weekdaySymbols.first, "M")
        XCTAssertEqual(grid.weekdaySymbols.count, 7)
    }

    func testMonthNavigation() {
        let cal = fixedCalendar()
        let grid = MonthGrid(containing: date(2026, 7, 17, in: cal), calendar: cal)
        XCTAssertEqual(grid.previousMonthStart, date(2026, 6, 1, in: cal))
        XCTAssertEqual(grid.nextMonthStart, date(2026, 8, 1, in: cal))
    }

    func testIsSameMonth() {
        let cal = fixedCalendar()
        let grid = MonthGrid(containing: date(2026, 7, 17, in: cal), calendar: cal)
        XCTAssertTrue(grid.isSameMonth(as: date(2026, 7, 31, in: cal)))
        XCTAssertFalse(grid.isSameMonth(as: date(2026, 8, 1, in: cal)))
    }

    func testTitleContainsYear() {
        let cal = fixedCalendar()
        let grid = MonthGrid(containing: date(2026, 7, 17, in: cal), calendar: cal)
        XCTAssertTrue(grid.title.contains("2026"))
    }
}
