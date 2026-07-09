import Foundation
import Observation
import CoreKit

@Observable
public final class WorkoutViewModel {
    public private(set) var title = "ワークアウト"

    public init() {}

    public func onAppear() async {
        AppLogger.general.debug("WorkoutView appeared")
    }

    /// Weight/reps to prefill a newly added set, copied from the previous one if present.
    public func defaultNextSet(previousSets: [SetEntry]) -> (weight: Double, reps: Int) {
        guard let last = previousSets.sorted(by: { $0.sortOrder < $1.sortOrder }).last else {
            return (0, 0)
        }
        return (last.weight, last.reps)
    }

    public func elapsedMinutes(start: Date, end: Date = Date()) -> Int {
        max(0, Int(end.timeIntervalSince(start) / 60))
    }
}
