import Foundation
import Observation
import CoreKit

@Observable
public final class HomeViewModel {
    private let restDayTargetStore: RestDayTargetStore

    public init(restDayTargetStore: RestDayTargetStore = .shared) {
        self.restDayTargetStore = restDayTargetStore
    }

    public func onAppear() async {
        AppLogger.general.debug("HomeView appeared")
    }

    public func weeklyMinutes(sessions: [WorkoutSession], referenceDate: Date = Date()) -> [WeeklyDayMinutes] {
        WeeklyTrainingSummary.minutesByDay(sessions: sessions, referenceDate: referenceDate)
    }

    public func restStatus(for group: MuscleGroup, sessions: [WorkoutSession], referenceDate: Date = Date()) -> RestStatus {
        RestDayCalculator.status(
            for: group,
            sessions: sessions,
            targetDays: restTarget(for: group),
            referenceDate: referenceDate
        )
    }

    public func restTarget(for group: MuscleGroup) -> Int {
        restDayTargetStore.target(for: group)
    }

    public func weekRangeLabel(referenceDate: Date = Date(), calendar: Calendar = .current) -> String {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: referenceDate) else { return "" }
        let end = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return "\(formatter.string(from: interval.start))〜\(formatter.string(from: end))"
    }
}
