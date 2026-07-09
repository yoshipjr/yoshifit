import Foundation
import SwiftData

public enum PersistenceController {
    public static let modelTypes: [any PersistentModel.Type] = [
        Exercise.self,
        WorkoutSession.self,
        WorkoutExerciseEntry.self,
        SetEntry.self,
        BodyRecord.self,
    ]

    @MainActor
    public static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            let container = try ModelContainer(
                for: Schema(modelTypes),
                configurations: [configuration]
            )
            seedExercisesIfNeeded(in: container)
            return container
        } catch {
            // No migration plan exists yet; if an incompatible local store is left over from an
            // earlier schema, reset it once rather than crashing outright.
            AppLogger.general.error("ModelContainer creation failed (\(error)); resetting local store.")
            deleteExistingStore()
            do {
                let container = try ModelContainer(
                    for: Schema(modelTypes),
                    configurations: [configuration]
                )
                seedExercisesIfNeeded(in: container)
                return container
            } catch {
                fatalError("Failed to create ModelContainer after resetting local store: \(error)")
            }
        }
    }

    private static func deleteExistingStore() {
        guard let appSupport = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return }

        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(at: appSupport.appending(path: "default.store\(suffix)"))
        }
    }

    @MainActor
    static func seedExercisesIfNeeded(in container: ModelContainer) {
        let context = container.mainContext
        let existingCount = (try? context.fetchCount(FetchDescriptor<Exercise>())) ?? 0
        guard existingCount == 0 else { return }

        for (index, seed) in ExerciseSeedData.all.enumerated() {
            let exercise = Exercise(
                name: seed.name,
                muscleGroup: seed.muscleGroup,
                sortOrder: index
            )
            context.insert(exercise)
        }
        try? context.save()
    }
}
