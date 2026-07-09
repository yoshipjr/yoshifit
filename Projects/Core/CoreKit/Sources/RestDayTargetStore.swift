import Foundation

/// Persists the user's customizable rest-day target per muscle group.
public final class RestDayTargetStore {
    public static let shared = RestDayTargetStore()

    private let defaults: UserDefaults
    private let keyPrefix = "restDayTarget."

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func target(for muscleGroup: MuscleGroup) -> Int {
        let key = keyPrefix + muscleGroup.rawValue
        let stored = defaults.integer(forKey: key)
        return stored > 0 ? stored : muscleGroup.defaultRestDayTarget
    }

    public func setTarget(_ days: Int, for muscleGroup: MuscleGroup) {
        defaults.set(days, forKey: keyPrefix + muscleGroup.rawValue)
    }
}
