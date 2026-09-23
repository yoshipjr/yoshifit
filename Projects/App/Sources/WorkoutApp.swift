import SwiftUI
import SwiftData
import UserNotifications
import CoreKit

@main
struct WorkoutApp: App {
    private let modelContainer = PersistenceController.makeContainer()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        UNUserNotificationCenter.current().delegate = ForegroundNotificationPresenter.shared
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                rescheduleOverdueReminder()
            }
        }
    }

    private func rescheduleOverdueReminder() {
        TrainingOverdueNotifier.requestAuthorizationIfNeeded { granted in
            guard granted else { return }
            DispatchQueue.main.async {
                TrainingOverdueNotifier.reschedule(using: modelContainer.mainContext)
            }
        }
    }
}
