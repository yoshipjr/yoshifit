import Foundation
import Observation
import CoreKit

@Observable
public final class CalendarViewModel {
    public private(set) var title = "カレンダー"
    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func onAppear() async {
        AppLogger.general.debug("CalendarView appeared")
    }

    public func monthLabel(for month: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 MM月"
        return formatter.string(from: month)
    }

    public func previousMonth(from month: Date) -> Date {
        calendar.date(byAdding: .month, value: -1, to: month) ?? month
    }

    public func nextMonth(from month: Date) -> Date {
        calendar.date(byAdding: .month, value: 1, to: month) ?? month
    }

    /// A 7-column grid of dates covering the full weeks of `month`, padded with `nil` for days outside it.
    public func gridDays(for month: Date) -> [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month),
            let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return [] }

        var days: [Date?] = []
        var current = firstWeek.start
        while current < monthInterval.end {
            if calendar.isDate(current, equalTo: month, toGranularity: .month) {
                days.append(current)
            } else {
                days.append(nil)
            }
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? monthInterval.end
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }

    public func sessions(on day: Date, in sessions: [WorkoutSession]) -> [WorkoutSession] {
        sessions
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.date < $1.date }
    }

    public func muscleGroups(on day: Date, in sessions: [WorkoutSession]) -> [MuscleGroup] {
        self.sessions(on: day, in: sessions).flatMap(\.muscleGroups).uniqued()
    }

    public struct MonthSummary {
        public let trainedDays: Int
        public let exerciseCount: Int
        public let totalMinutes: Int
    }

    public func monthSummary(for month: Date, sessions: [WorkoutSession]) -> MonthSummary {
        let sessionsInMonth = sessions.filter {
            calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
        let trainedDays = Set(sessionsInMonth.map { calendar.startOfDay(for: $0.date) }).count
        let exerciseCount = sessionsInMonth.reduce(0) { $0 + $1.entries.count }
        let totalMinutes = sessionsInMonth.reduce(0) { $0 + $1.durationMinutes }
        return MonthSummary(trainedDays: trainedDays, exerciseCount: exerciseCount, totalMinutes: totalMinutes)
    }

    public struct DaySessions: Identifiable {
        public let date: Date
        public let sessions: [WorkoutSession]
        public var id: Date { date }
    }

    /// All sessions in `month`, grouped by day and sorted newest-day-first.
    public func sessionsByDay(for month: Date, sessions: [WorkoutSession]) -> [DaySessions] {
        let sessionsInMonth = sessions.filter {
            calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
        let grouped = Dictionary(grouping: sessionsInMonth) { calendar.startOfDay(for: $0.date) }
        return grouped
            .map { DaySessions(date: $0.key, sessions: $0.value.sorted { $0.date < $1.date }) }
            .sorted { $0.date > $1.date }
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
