import Foundation
import SwiftData
import UserNotifications

/// Lets notifications banner even while the app is in the foreground
/// (otherwise a test notification fired from Settings would be silently
/// delivered to Notification Center with no visible banner).
public final class ForegroundNotificationPresenter: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = ForegroundNotificationPresenter()

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

/// Schedules a local notification warning about muscle groups that have exceeded
/// their rest-day target (see `RestDayTargetStore` / `RestDayCalculator`).
public enum TrainingOverdueNotifier {
    public static let notificationIdentifier = "trainingOverdueReminder"

    public static func requestAuthorizationIfNeeded(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion?(true)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion?(granted)
                }
            default:
                completion?(false)
            }
        }
    }

    public static func overdueGroups(
        sessions: [WorkoutSession],
        targetStore: RestDayTargetStore = .shared,
        referenceDate: Date = Date()
    ) -> [(group: MuscleGroup, daysOverdue: Int)] {
        MuscleGroup.allCases.compactMap { group in
            let target = targetStore.target(for: group)
            let status = RestDayCalculator.status(
                for: group,
                sessions: sessions,
                targetDays: target,
                referenceDate: referenceDate
            )
            if case .overdue(let days) = status {
                return (group, days)
            }
            return nil
        }
    }

    /// Fetches sessions from `context` and reschedules the daily reminder.
    public static func reschedule(using context: ModelContext, hour: Int = 8, minute: Int = 0) {
        let sessions = (try? context.fetch(FetchDescriptor<WorkoutSession>())) ?? []
        scheduleDailyReminder(sessions: sessions, hour: hour, minute: minute)
    }

    /// Recomputes overdue groups from `sessions` and (re)schedules the next 8:00 notification.
    /// Non-repeating: fires once at the next occurrence of `hour:minute`, so the caller should
    /// re-invoke this (e.g. on app foreground, or after logging/finishing a workout) to keep
    /// tomorrow's content accurate.
    public static func scheduleDailyReminder(sessions: [WorkoutSession], hour: Int = 8, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])

        guard let content = overdueContent(sessions: sessions) else { return }

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

    /// Fires a one-off test notification a few seconds from now, using the same overdue
    /// content that the real 8:00 reminder would show. For manually verifying the feature
    /// without waiting for the scheduled time.
    public static func sendTestNotification(sessions: [WorkoutSession], after seconds: TimeInterval = 5) {
        let content = overdueContent(sessions: sessions)
            ?? { () -> UNMutableNotificationContent in
                let content = UNMutableNotificationContent()
                content.title = "トレーニング超過のお知らせ（テスト）"
                content.body = "現在、休息目標を超えている部位はありません。"
                content.sound = .default
                return content
            }()

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "\(notificationIdentifier).test", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private static func overdueContent(sessions: [WorkoutSession]) -> UNMutableNotificationContent? {
        let overdue = overdueGroups(sessions: sessions)
        guard !overdue.isEmpty else { return nil }

        let content = UNMutableNotificationContent()
        content.title = "トレーニング超過のお知らせ"
        content.body = overdue
            .map { "\($0.group.displayName)が目標の休息日数を\($0.daysOverdue)日超えています" }
            .joined(separator: "\n")
        content.sound = .default
        return content
    }
}
