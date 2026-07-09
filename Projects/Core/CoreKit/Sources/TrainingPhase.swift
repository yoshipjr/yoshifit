import Foundation

public enum TrainingPhase: String, CaseIterable, Codable, Identifiable {
    case diet
    case bulkUp

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .diet: "ダイエット"
        case .bulkUp: "バルクアップ"
        }
    }

    public var shortLabel: String {
        switch self {
        case .diet: "D"
        case .bulkUp: "B"
        }
    }
}
