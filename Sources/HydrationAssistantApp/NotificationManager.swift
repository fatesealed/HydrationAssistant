import Foundation
import HydrationAssistantDomain
@preconcurrency
import UserNotifications

@MainActor
final class NotificationManager {
    func requestAuthorizationIfNeeded() {
        Task {
            _ = await requestAuthorizationIfNeededAsync()
        }
    }

    func send(reminder: ReminderKind) {
        Task {
            guard await requestAuthorizationIfNeededAsync() else { return }
            let content = UNMutableNotificationContent()
            content.title = "该喝水了"
            content.body = "小水獭提醒你喝一口，今天离目标又近一点。"
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: "hydration-\(reminder.rawValue)-\(UUID().uuidString)",
                content: content,
                trigger: nil
            )

            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    func sendTestNotification() {
        Task {
            guard await requestAuthorizationIfNeededAsync() else { return }
            let content = UNMutableNotificationContent()
            content.title = "测试提示"
            content.body = "这是一条测试提醒，说明通知功能可用。"
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: "hydration-test-\(UUID().uuidString)",
                content: content,
                trigger: nil
            )

            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    private func requestAuthorizationIfNeededAsync() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .denied:
            return false
        @unknown default:
            return false
        }
    }
}
