import Foundation

public enum MuscleGroup: String, CaseIterable, Codable, Identifiable {
    case chest
    case back
    case shoulder
    case biceps
    case triceps
    case legs
    case abs

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .chest: "胸"
        case .back: "背中"
        case .shoulder: "肩"
        case .biceps: "二頭・前腕"
        case .triceps: "三頭"
        case .legs: "脚"
        case .abs: "腹筋"
        }
    }

    /// Default number of rest days recommended before training this group again.
    public var defaultRestDayTarget: Int { 4 }
}
