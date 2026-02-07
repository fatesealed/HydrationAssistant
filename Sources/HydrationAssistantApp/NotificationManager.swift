import Foundation
import HydrationAssistantDomain
import UserNotifications

@MainActor
final class NotificationManager {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorizationIfNeeded() {
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func send(reminder: ReminderKind) {
        let content = UNMutableNotificationContent()

        switch reminder {
        case .drink:
            content.title = "该喝水了"
            content.body = "小水獭提醒你喝一口，今天离目标又近一点。"
        case .refill:
            content.title = "该接水了"
            content.body = "你的杯子快空了，先去接满再继续喝。"
        }

        content.sound = nil

        let request = UNNotificationRequest(
            identifier: "hydration-\(reminder.rawValue)-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        center.add(request) { _ in }
    }
}
