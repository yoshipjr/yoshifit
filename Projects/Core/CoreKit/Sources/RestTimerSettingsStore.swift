import Foundation

/// Persists the user's rest-timer preferences (shown from the workout editor's rest timer popup).
public final class RestTimerSettingsStore {
    public static let shared = RestTimerSettingsStore()

    private enum Keys {
        static let popupEnabled = "restTimer.popupEnabled"
        static let alarmEnabled = "restTimer.alarmEnabled"
        static let volume = "restTimer.volume"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var isPopupEnabled: Bool {
        get { defaults.object(forKey: Keys.popupEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.popupEnabled) }
    }

    public var isAlarmSoundEnabled: Bool {
        get { defaults.object(forKey: Keys.alarmEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.alarmEnabled) }
    }

    public var volume: Double {
        get { defaults.object(forKey: Keys.volume) as? Double ?? 0.8 }
        set { defaults.set(newValue, forKey: Keys.volume) }
    }
}
