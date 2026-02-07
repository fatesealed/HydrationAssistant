import Foundation
import HydrationAssistantDomain
@preconcurrency
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let actionHalfCup = "drink_half_cup"
    static let actionOneCup = "drink_one_cup"
    static let userActionNotification = Notification.Name("HydrationUserActionNotification")

    enum SendResult {
        case sent
        case denied
        case failed
    }

    override init() {
        super.init()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let half = UNNotificationAction(
            identifier: Self.actionHalfCup,
            title: "我已经喝了半杯水",
            options: []
        )
        let one = UNNotificationAction(
            identifier: Self.actionOneCup,
            title: "我已经喝了一杯水",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: "hydration_drink_category",
            actions: [half, one],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }

    @MainActor
    func requestAuthorizationIfNeeded() async -> Bool {
        await requestAuthorizationIfNeededAsync()
    }

    @MainActor
    func send(reminder: ReminderKind) async -> SendResult {
        guard await requestAuthorizationIfNeededAsync() else { return .denied }
        let content = UNMutableNotificationContent()
        content.title = "该喝水了"
        content.body = "小水獭提醒你喝一口，今天离目标又近一点。直接点击通知会记为喝了半杯水。"
        content.sound = .default
        content.categoryIdentifier = "hydration_drink_category"

        let request = UNNotificationRequest(
            identifier: "hydration-\(reminder.rawValue)-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            return .sent
        } catch {
            return .failed
        }
    }

    @MainActor
    func sendTestNotification() async -> SendResult {
        let granted = await requestAuthorizationIfNeededAsync()
        guard granted else { return .denied }

        let content = UNMutableNotificationContent()
        content.title = "测试提示"
        content.body = "这是一条测试提醒，说明通知功能可用。"
        content.sound = .default
        content.categoryIdentifier = "hydration_drink_category"

        let request = UNNotificationRequest(
            identifier: "hydration-test-\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            return .sent
        } catch {
            return .failed
        }
    }

    @MainActor
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

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let id = response.actionIdentifier
        let category = response.notification.request.content.categoryIdentifier
        if id == UNNotificationDefaultActionIdentifier, category == "hydration_drink_category" {
            NotificationCenter.default.post(
                name: Self.userActionNotification,
                object: nil,
                userInfo: ["action": Self.actionHalfCup]
            )
        } else if id == Self.actionHalfCup || id == Self.actionOneCup {
            NotificationCenter.default.post(
                name: Self.userActionNotification,
                object: nil,
                userInfo: ["action": id]
            )
        }
    }
}
