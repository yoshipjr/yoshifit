import Foundation

public enum RestStatus: Equatable {
    /// This muscle group has never been trained.
    case noHistory
    /// Still resting; the number of days left before the target is reached.
    case remaining(Int)
    /// Past the target; the number of days since it was last trained.
    case overdue(Int)
}

public enum RestDayCalculator {
    public static func status(
        for muscleGroup: MuscleGroup,
        sessions: [WorkoutSession],
        targetDays: Int,
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> RestStatus {
        let lastDate = sessions
            .filter { $0.muscleGroups.contains(muscleGroup) }
            .map(\.date)
            .max()

        guard let lastDate else { return .noHistory }

        let startOfLast = calendar.startOfDay(for: lastDate)
        let startOfReference = calendar.startOfDay(for: referenceDate)
        let daysSince = calendar.dateComponents([.day], from: startOfLast, to: startOfReference).day ?? 0

        if daysSince >= targetDays {
            return .overdue(daysSince)
        }
        return .remaining(targetDays - daysSince)
    }
}
