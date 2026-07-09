import Foundation

public struct WeeklyDayMinutes: Identifiable, Equatable {
    public let date: Date
    public let minutes: Int
    public var id: Date { date }

    public init(date: Date, minutes: Int) {
        self.date = date
        self.minutes = minutes
    }
}

public enum WeeklyTrainingSummary {
    /// Minutes trained per day for the Sun–Sat week containing `referenceDate`.
    public static func minutesByDay(
        sessions: [WorkoutSession],
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> [WeeklyDayMinutes] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: referenceDate) else {
            return []
        }
        let days = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekInterval.start)
        }
        return days.map { day in
            let total = sessions
                .filter { calendar.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + $1.durationMinutes }
            return WeeklyDayMinutes(date: day, minutes: total)
        }
    }

    public static func totalMinutes(sessions: [WorkoutSession], referenceDate: Date = Date(), calendar: Calendar = .current) -> Int {
        minutesByDay(sessions: sessions, referenceDate: referenceDate, calendar: calendar)
            .reduce(0) { $0 + $1.minutes }
    }
}
