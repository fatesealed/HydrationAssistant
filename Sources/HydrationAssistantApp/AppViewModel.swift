import Foundation
import HydrationAssistantDomain
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var store: HydrationAppStore
    @Published var workSchedule: WorkSchedule
    @Published var snoozeMinutes: Int = 15
    private let notificationManager = NotificationManager()
    private var lastNotificationAt: Date?
    private var lastReminderKind: ReminderKind?
    private var timer: Timer?

    init() {
        let profile = UserProfile(weightKg: 60, gender: .female, age: 28, cupCapacityMl: 500)
        let targetMl = GoalCalculator.dailyTargetMl(profile: profile)
        self.store = HydrationAppStore(profile: profile, targetMl: targetMl)
        self.workSchedule = WorkSchedule(
            workStartHour: 9,
            workStartMinute: 0,
            workEndHour: 18,
            workEndMinute: 0,
            lunchStartHour: 12,
            lunchStartMinute: 0,
            lunchEndHour: 13,
            lunchEndMinute: 30
        )

        notificationManager.requestAuthorizationIfNeeded()
        startReminderLoop()
    }

    var progressText: String {
        "\(store.state.consumedMl) / \(store.state.targetMl) ml"
    }

    var cupText: String {
        "杯中约 \(store.state.cupRemainingMl) ml"
    }

    var animalText: String {
        switch store.animalMood {
        case .happy:
            return "小水獭超开心"
        case .okay:
            return "小水獭状态不错"
        case .thirsty:
            return "小水獭有点口渴"
        }
    }

    var animalSymbol: String {
        switch store.animalMood {
        case .happy:
            return "face.smiling.inverse"
        case .okay:
            return "face.dashed"
        case .thirsty:
            return "drop.triangle"
        }
    }

    func drinkHalfCup() {
        store.drinkHalfCup()
        evaluateReminder(now: Date())
        objectWillChange.send()
    }

    func drinkOneCup() {
        store.drinkOneCup()
        evaluateReminder(now: Date())
        objectWillChange.send()
    }

    func refillCup() {
        store.refillCup()
        evaluateReminder(now: Date())
        objectWillChange.send()
    }

    func snooze() {
        store.snooze(minutes: snoozeMinutes)
        objectWillChange.send()
    }

    private func startReminderLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.evaluateReminder(now: Date())
            }
        }
        evaluateReminder(now: Date())
    }

    private func evaluateReminder(now: Date) {
        let active = ScheduleEvaluator.isReminderActive(now: now, schedule: workSchedule)
        let decision = NotificationDecision.nextReminder(
            state: store.state,
            isInReminderWindow: active,
            refillThreshold: 0.2
        )

        guard let reminder = decision else {
            return
        }

        if shouldNotify(now: now, reminder: reminder) {
            notificationManager.send(reminder: reminder)
            lastNotificationAt = now
            lastReminderKind = reminder
        }
    }

    private func shouldNotify(now: Date, reminder: ReminderKind) -> Bool {
        if let snooze = store.snoozedMinutes, let last = lastNotificationAt {
            if now.timeIntervalSince(last) < Double(snooze * 60) {
                return false
            }
        }

        guard let last = lastNotificationAt, let lastKind = lastReminderKind else {
            return true
        }

        let minInterval: TimeInterval = (lastKind == reminder) ? 20 * 60 : 10 * 60
        return now.timeIntervalSince(last) >= minInterval
    }
}
