import Foundation
import Observation

public enum RootTab: Hashable {
    case home, calendar, workout, menu, settings
}

/// Shared cross-feature navigation state (selected tab, pending deep-link targets).
@Observable
public final class AppRouter {
    public static let shared = AppRouter()

    public var selectedTab: RootTab = .home
    public var pendingCalendarDate: Date?

    public init() {}

    public func showCalendar(for date: Date) {
        pendingCalendarDate = date
        selectedTab = .calendar
    }
}
