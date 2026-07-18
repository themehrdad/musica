import Foundation

/// Calendar math for the progress month view: lays a month's days into
/// 7-column rows, padded with blanks so weeks align to the calendar's
/// first weekday. Pure math, no UI — see MonthGridTests.
struct MonthGrid {
    let monthStart: Date
    let calendar: Calendar

    init(containing date: Date, calendar: Calendar = .current) {
        self.calendar = calendar
        let components = calendar.dateComponents([.year, .month], from: date)
        self.monthStart = calendar.date(from: components) ?? date
    }

    /// One entry per grid cell in reading order; nil for the leading and
    /// trailing blanks that pad the first and last week.
    var cells: [Date?] {
        guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        var result: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in dayRange {
            result.append(calendar.date(byAdding: .day, value: day - 1, to: monthStart))
        }
        while result.count % 7 != 0 {
            result.append(nil)
        }
        return result
    }

    /// Weekday symbols reordered to start at the calendar's first weekday.
    var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }

    var previousMonthStart: Date {
        calendar.date(byAdding: .month, value: -1, to: monthStart) ?? monthStart
    }

    var nextMonthStart: Date {
        calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
    }

    func isSameMonth(as date: Date) -> Bool {
        calendar.isDate(monthStart, equalTo: date, toGranularity: .month)
    }

    private static let titleFormatter: DateFormatter = {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("yMMMM")
        return f
    }()

    var title: String {
        Self.titleFormatter.string(from: monthStart)
    }
}
