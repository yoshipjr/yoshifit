import Foundation
import Observation
import CoreKit

public enum MenuTab: Hashable {
    case favorites
    case muscleGroup(MuscleGroup)

    public var title: String {
        switch self {
        case .favorites: "お気に入り"
        case .muscleGroup(let group): group.displayName
        }
    }
}

public enum MenuSort: String, CaseIterable, Identifiable {
    case `default`
    case name

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .default: "デフォルト"
        case .name: "名前順"
        }
    }
}

@Observable
public final class MenuViewModel {
    public private(set) var title = "メニュー"

    public init() {}

    public func onAppear() async {
        AppLogger.general.debug("MenuView appeared")
    }

    public static let tabs: [MenuTab] = [.favorites] + MuscleGroup.allCases.map(MenuTab.muscleGroup)

    public func filteredExercises(
        _ exercises: [Exercise],
        tab: MenuTab?,
        searchText: String,
        sort: MenuSort
    ) -> [Exercise] {
        var result = exercises

        switch tab {
        case nil:
            break
        case .favorites:
            result = result.filter(\.isFavorite)
        case .muscleGroup(let group):
            result = result.filter { $0.muscleGroup == group }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        switch sort {
        case .default:
            result.sort { $0.sortOrder < $1.sortOrder }
        case .name:
            result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        }

        return result
    }
}
