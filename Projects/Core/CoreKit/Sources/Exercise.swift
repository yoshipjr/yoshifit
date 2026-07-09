import Foundation
import SwiftData

@Model
public final class Exercise {
    public var id: UUID
    public var name: String
    public var muscleGroupRaw: String
    public var isFavorite: Bool
    public var sortOrder: Int

    public init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        isFavorite: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.muscleGroupRaw = muscleGroup.rawValue
        self.isFavorite = isFavorite
        self.sortOrder = sortOrder
    }

    public var muscleGroup: MuscleGroup {
        get { MuscleGroup(rawValue: muscleGroupRaw) ?? .chest }
        set { muscleGroupRaw = newValue.rawValue }
    }
}
