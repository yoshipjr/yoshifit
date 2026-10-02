import Foundation
import HealthKit

/// Write-only HealthKit integration: records a finished `WorkoutSession` as an
/// `HKWorkout` so it shows up in the Health app and Activity rings. Never reads
/// HealthKit data back into the app.
public final class HealthKitWriter {
    public static let shared = HealthKitWriter()

    private let store = HKHealthStore()

    private var shareTypes: Set<HKSampleType> {
        var types: Set<HKSampleType> = [HKObjectType.workoutType()]
        if let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(energyType)
        }
        return types
    }

    public func saveWorkout(session: WorkoutSession) {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        store.requestAuthorization(toShare: shareTypes, read: []) { [weak self] granted, error in
            guard granted else {
                if let error {
                    AppLogger.general.error("HealthKit authorization failed: \(error)")
                }
                return
            }
            self?.write(session: session)
        }
    }

    private func write(session: WorkoutSession) {
        let end = session.finishedAt ?? Date()
        let start = session.startedAt ?? end.addingTimeInterval(-TimeInterval(session.durationMinutes * 60))
        let energy: HKQuantity? = session.caloriesBurned > 0
            ? HKQuantity(unit: .kilocalorie(), doubleValue: Double(session.caloriesBurned))
            : nil

        let workout = HKWorkout(
            activityType: .traditionalStrengthTraining,
            start: start,
            end: end,
            duration: end.timeIntervalSince(start),
            totalEnergyBurned: energy,
            totalDistance: nil,
            metadata: nil
        )

        store.save(workout) { success, error in
            if let error {
                AppLogger.general.error("HealthKit save failed: \(error)")
            } else if !success {
                AppLogger.general.error("HealthKit save returned false without an error")
            }
        }
    }
}
