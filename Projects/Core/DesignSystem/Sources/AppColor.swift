import SwiftUI
import CoreKit

public enum AppColor {
    /// yoshifit brand green.
    public static let brand = Color(red: 0.55, green: 0.78, blue: 0.16)
    public static let accent = brand
    public static let screenBackground = Color(.secondarySystemBackground)
    public static let cardBackground = Color(.systemBackground)
    public static let background = Color(.systemBackground)
    public static let secondaryText = Color.secondary
    public static let warning = Color.orange
    public static let danger = Color(red: 0.93, green: 0.27, blue: 0.27)
}

public extension MuscleGroup {
    var color: Color {
        switch self {
        case .chest: Color(red: 0.95, green: 0.28, blue: 0.38)
        case .back: Color(red: 0.30, green: 0.69, blue: 0.31)
        case .shoulder: Color(red: 1.00, green: 0.60, blue: 0.00)
        case .biceps: Color(red: 1.00, green: 0.76, blue: 0.03)
        case .triceps: Color(red: 0.55, green: 0.76, blue: 0.29)
        case .legs: Color(red: 0.15, green: 0.78, blue: 0.86)
        case .abs: Color(red: 0.67, green: 0.28, blue: 0.74)
        }
    }
}
