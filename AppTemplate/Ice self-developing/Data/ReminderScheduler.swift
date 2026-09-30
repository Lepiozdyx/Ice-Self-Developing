import Foundation
import UserNotifications

@MainActor
enum ReminderScheduler {
    private static let morningID = "ice.morning-spark"
    private static let eveningID = "ice.evening-honesty"
    private static let delegate = NotificationPresenter()

    static func enable() async -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = delegate
        let granted = await authorizationGranted(center)
        guard granted else { return false }
        center.removePendingNotificationRequests(withIdentifiers: [morningID, eveningID])
        schedule(
            id: morningID,
            title: "Morning Spark",
            body: "What matters most to you today?",
            hour: 8,
            center: center
        )
        schedule(
            id: eveningID,
            title: "Evening Honesty",
            body: "Were you the author of your day?",
            hour: 21,
            center: center
        )
        return true
    }

    static func disable() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [morningID, eveningID])
    }

    private static func authorizationGranted(_ center: UNUserNotificationCenter) async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    private static func schedule(
        id: String,
        title: String,
        body: String,
        hour: Int,
        center: UNUserNotificationCenter
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}

private final class NotificationPresenter: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
