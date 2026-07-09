import Foundation
import SwiftData

@Model
public final class BodyRecord {
    public var id: UUID
    public var date: Date
    public var weight: Double?
    public var bodyFatPercentage: Double?
    public var muscleMass: Double?
    public var phaseRaw: String?

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        weight: Double? = nil,
        bodyFatPercentage: Double? = nil,
        muscleMass: Double? = nil,
        phase: TrainingPhase? = nil
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.muscleMass = muscleMass
        self.phaseRaw = phase?.rawValue
    }

    public var phase: TrainingPhase? {
        get { phaseRaw.flatMap(TrainingPhase.init(rawValue:)) }
        set { phaseRaw = newValue?.rawValue }
    }
}
