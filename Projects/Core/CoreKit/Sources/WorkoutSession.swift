import Foundation
import SwiftData

@Model
public final class WorkoutSession {
    public var id: UUID
    public var date: Date
    public var durationMinutes: Int
    public var caloriesBurned: Int = 0
    /// When the user tapped "トレーニングを開始する" for a live, same-day workout.
    public var startedAt: Date?
    /// When the user tapped "終了" to complete a live, same-day workout.
    public var finishedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExerciseEntry.session)
    public var entries: [WorkoutExerciseEntry]

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        durationMinutes: Int = 0,
        caloriesBurned: Int = 0,
        startedAt: Date? = nil,
        finishedAt: Date? = nil,
        entries: [WorkoutExerciseEntry] = []
    ) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.entries = entries
    }

    public var muscleGroups: [MuscleGroup] {
        var seen = Set<MuscleGroup>()
        var result: [MuscleGroup] = []
        for entry in entries.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            if seen.insert(entry.muscleGroup).inserted {
                result.append(entry.muscleGroup)
            }
        }
        return result
    }

    public var totalVolume: Double {
        entries.reduce(0) { $0 + $1.totalVolume }
    }
}

@Model
public final class WorkoutExerciseEntry {
    public var id: UUID
    public var exerciseName: String
    public var muscleGroupRaw: String
    public var memo: String
    public var sortOrder: Int
    public var session: WorkoutSession?

    @Relationship(deleteRule: .cascade, inverse: \SetEntry.exerciseEntry)
    public var sets: [SetEntry]

    public init(
        id: UUID = UUID(),
        exerciseName: String,
        muscleGroup: MuscleGroup,
        memo: String = "",
        sortOrder: Int = 0,
        sets: [SetEntry] = []
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.muscleGroupRaw = muscleGroup.rawValue
        self.memo = memo
        self.sortOrder = sortOrder
        self.sets = sets
    }

    public var muscleGroup: MuscleGroup {
        get { MuscleGroup(rawValue: muscleGroupRaw) ?? .chest }
        set { muscleGroupRaw = newValue.rawValue }
    }

    public var totalVolume: Double {
        sets.reduce(0) { $0 + $1.weight * Double($1.reps) }
    }

    /// Estimated 1RM of the best set, via the Epley formula.
    public var estimatedOneRepMax: Double? {
        sets.filter { $0.reps > 0 }
            .map { $0.weight * (1 + Double($0.reps) / 30) }
            .max()
    }
}

@Model
public final class SetEntry {
    public var id: UUID
    public var weight: Double
    public var reps: Int
    public var isCompleted: Bool
    public var sortOrder: Int
    public var exerciseEntry: WorkoutExerciseEntry?

    public init(
        id: UUID = UUID(),
        weight: Double = 0,
        reps: Int = 0,
        isCompleted: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
    }

    public var oneRepMax: Double? {
        guard reps > 0, weight > 0 else { return nil }
        return weight * (1 + Double(reps) / 30)
    }
}
