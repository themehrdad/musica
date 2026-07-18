import SwiftUI
import SwiftData

/// The Progress tab: a month calendar showing each day's score for one
/// profile, a gold star on days the daily goal was reached, and — for a
/// tapped day — the list of notes practiced that day.
struct ProgressCalendarView: View {
    let profile: Profile
    @Environment(\.dismiss) private var dismiss
    @State private var monthAnchor: Date = .now
    @State private var selectedDate: Date? = .now

    private var grid: MonthGrid { MonthGrid(containing: monthAnchor) }

    /// Day-key ("2026-07-17") → progress record for this profile.
    private var progressByDay: [String: DailyProgress] {
        Dictionary((profile.dailyProgress ?? []).map { ($0.date, $0) },
                   uniquingKeysWith: { first, _ in first })
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(spacing: 16) {
                    monthHeader
                    calendarGrid
                    if let selected = selectedDate {
                        DayDetailView(
                            date: selected,
                            progress: progressByDay[DailyProgress.dayString(from: selected)]
                        )
                        .id(DailyProgress.dayString(from: selected))
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemBackground))
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 8) {
                    AvatarView(name: profile.name,
                               imageData: profile.avatarData, size: 36)
                    Text(profile.name)
                        .font(.headline)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    monthAnchor = grid.previousMonthStart
                }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.purple.opacity(0.7))
            }

            Spacer()

            Text(grid.title)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(
                    LinearGradient(colors: [.purple, .blue],
                                   startPoint: .leading, endPoint: .trailing)
                )

            Spacer()

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    monthAnchor = grid.nextMonthStart
                }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.purple.opacity(0.7))
            }
            .disabled(grid.isSameMonth(as: .now))
            .opacity(grid.isSameMonth(as: .now) ? 0.3 : 1)
        }
        .padding(.top, 8)
    }

    private var calendarGrid: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                ForEach(Array(grid.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7),
                      spacing: 6) {
                ForEach(Array(grid.cells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        DayCellView(
                            date: day,
                            score: progressByDay[DailyProgress.dayString(from: day)]?.notesCompleted,
                            isSelected: isSelected(day)
                        )
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.25)) {
                                selectedDate = day
                            }
                        }
                    } else {
                        Color.clear.frame(height: 58)
                    }
                }
            }
        }
    }

    private func isSelected(_ day: Date) -> Bool {
        guard let selectedDate else { return false }
        return Calendar.current.isDate(day, inSameDayAs: selectedDate)
    }
}

/// One day square: day number top-left, score in the middle, and a gold
/// star riding the top-right corner once the daily goal is reached.
struct DayCellView: View {
    let date: Date
    let score: Int?          // nil = no practice recorded
    let isSelected: Bool

    private var starred: Bool { (score ?? 0) >= Config.dailyGoal }
    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var isFuture: Bool { date > Date() && !isToday }
    private var dayNumber: Int { Calendar.current.component(.day, from: date) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(background)

            Text("\(dayNumber)")
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(isToday ? Color.white : .secondary)
                .frame(minWidth: 16, minHeight: 16)
                .background(
                    Circle().fill(isToday ? Color.blue : .clear)
                )
                .padding(3)

            if let score {
                Text("\(score)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(starred ? Color.orange : .primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 8)
            }
        }
        .frame(height: 58)
        .opacity(isFuture ? 0.35 : 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isSelected
                        ? AnyShapeStyle(LinearGradient(colors: [.purple, .blue],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing))
                        : AnyShapeStyle(.clear),
                    lineWidth: 2
                )
        )
        .overlay(alignment: .topTrailing) {
            if starred {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 2)
                    .offset(x: 4, y: -5)
            }
        }
    }

    private var background: Color {
        if starred { return .yellow.opacity(0.18) }
        if score != nil { return .purple.opacity(0.10) }
        return Color(.secondarySystemBackground)
    }
}

/// The card under the calendar for the tapped day: score, star status,
/// and which notes were practiced (when the day recorded them).
struct DayDetailView: View {
    let date: Date
    let progress: DailyProgress?

    private var score: Int { progress?.notesCompleted ?? 0 }
    private var starred: Bool { score >= Config.dailyGoal }

    /// Practiced notes deduplicated in first-played order, with counts.
    private var noteCounts: [(note: String, count: Int)] {
        guard let notes = progress?.practicedNotes, !notes.isEmpty else { return [] }
        var order: [String] = []
        var counts: [String: Int] = [:]
        for note in notes {
            if counts[note] == nil { order.append(note) }
            counts[note, default: 0] += 1
        }
        return order.map { ($0, counts[$0] ?? 0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.system(.headline, design: .rounded))

            if progress == nil {
                Label("No practice this day", systemImage: "moon.zzz.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 16) {
                    Label("\(score) notes", systemImage: "music.note")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    if starred {
                        Label("Goal reached!", systemImage: "star.fill")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.orange)
                    } else {
                        Text("\(Config.dailyGoal - score) to go for a star")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if noteCounts.isEmpty {
                    Text("The note list wasn't recorded for this day.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 62), spacing: 8)],
                              alignment: .leading, spacing: 8) {
                        ForEach(noteCounts, id: \.note) { entry in
                            Text(entry.count > 1 ? "\(entry.note) ×\(entry.count)" : entry.note)
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule().fill(.purple.opacity(0.12))
                                )
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
