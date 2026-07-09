import Foundation
import Observation
import CoreKit

@Observable
public final class SettingsViewModel {
    public private(set) var title = "設定"
    private let restDayTargetStore: RestDayTargetStore

    public init(restDayTargetStore: RestDayTargetStore = .shared) {
        self.restDayTargetStore = restDayTargetStore
    }

    public func onAppear() async {
        AppLogger.general.debug("SettingsView appeared")
    }

    public func restTarget(for group: MuscleGroup) -> Int {
        restDayTargetStore.target(for: group)
    }

    public func setRestTarget(_ days: Int, for group: MuscleGroup) {
        restDayTargetStore.setTarget(days, for: group)
    }
}
