import Foundation
import HydrationAssistantDomain
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    enum TargetMode: String, CaseIterable {
        case auto
        case manual
    }

    @Published private(set) var store: HydrationAppStore
    @Published var workSchedule: WorkSchedule
    @Published var snoozeMinutes: Int
    @Published var targetMode: TargetMode
    @Published var manualTargetMl: Int
    @Published var manualTargetInput: String
    @Published var weightKg: Int
    @Published var age: Int
    @Published var cupCapacityMl: Int
    @Published var weightInput: String
    @Published var ageInput: String
    @Published var cupCapacityInput: String
    @Published var gender: Gender
    @Published var workStartTime: Date
    @Published var workEndTime: Date
    @Published var lunchStartTime: Date
    @Published var lunchEndTime: Date
    @Published var actionMessage: String?
    @Published private(set) var hasCompletedOnboarding: Bool
    @Published private(set) var isWorking: Bool

    private let notificationManager = NotificationManager()
    private var notificationActionObserver: NSObjectProtocol?
    private var lastNotificationAt: Date?
    private var lastReminderKind: ReminderKind?
    private var timer: Timer?

    private static let defaultProfile = UserProfile(weightKg: 60, gender: .female, age: 28, cupCapacityMl: 500)
    private static let defaultSchedule = WorkSchedule(
        workStartHour: 9,
        workStartMinute: 0,
        workEndHour: 18,
        workEndMinute: 0,
        lunchStartHour: 12,
        lunchStartMinute: 0,
        lunchEndHour: 13,
        lunchEndMinute: 30
    )

    private enum Keys {
        static let weightKg = "weightKg"
        static let age = "age"
        static let cupCapacityMl = "cupCapacityMl"
        static let gender = "gender"
        static let workStartHour = "workStartHour"
        static let workStartMinute = "workStartMinute"
        static let workEndHour = "workEndHour"
        static let workEndMinute = "workEndMinute"
        static let lunchStartHour = "lunchStartHour"
        static let lunchStartMinute = "lunchStartMinute"
        static let lunchEndHour = "lunchEndHour"
        static let lunchEndMinute = "lunchEndMinute"
        static let snoozeMinutes = "snoozeMinutes"
        static let targetMode = "targetMode"
        static let manualTargetMl = "manualTargetMl"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isWorking = "isWorking"
    }

    init() {
        let defaults = UserDefaults.standard

        let profile = UserProfile(
            weightKg: defaults.integer(forKey: Keys.weightKg) > 0 ? defaults.integer(forKey: Keys.weightKg) : Self.defaultProfile.weightKg,
            gender: Gender(rawValue: defaults.string(forKey: Keys.gender) ?? "") ?? Self.defaultProfile.gender,
            age: defaults.integer(forKey: Keys.age) > 0 ? defaults.integer(forKey: Keys.age) : Self.defaultProfile.age,
            cupCapacityMl: defaults.integer(forKey: Keys.cupCapacityMl) > 0 ? defaults.integer(forKey: Keys.cupCapacityMl) : Self.defaultProfile.cupCapacityMl
        )

        let schedule = WorkSchedule(
            workStartHour: defaults.integer(forKey: Keys.workStartHour) > 0 ? defaults.integer(forKey: Keys.workStartHour) : Self.defaultSchedule.workStartHour,
            workStartMinute: defaults.integer(forKey: Keys.workStartMinute),
            workEndHour: defaults.integer(forKey: Keys.workEndHour) > 0 ? defaults.integer(forKey: Keys.workEndHour) : Self.defaultSchedule.workEndHour,
            workEndMinute: defaults.integer(forKey: Keys.workEndMinute),
            lunchStartHour: defaults.integer(forKey: Keys.lunchStartHour) > 0 ? defaults.integer(forKey: Keys.lunchStartHour) : Self.defaultSchedule.lunchStartHour,
            lunchStartMinute: defaults.integer(forKey: Keys.lunchStartMinute),
            lunchEndHour: defaults.integer(forKey: Keys.lunchEndHour) > 0 ? defaults.integer(forKey: Keys.lunchEndHour) : Self.defaultSchedule.lunchEndHour,
            lunchEndMinute: defaults.integer(forKey: Keys.lunchEndMinute) > 0 ? defaults.integer(forKey: Keys.lunchEndMinute) : Self.defaultSchedule.lunchEndMinute
        )

        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        self.isWorking = defaults.bool(forKey: Keys.isWorking)
        self.snoozeMinutes = defaults.integer(forKey: Keys.snoozeMinutes) > 0 ? defaults.integer(forKey: Keys.snoozeMinutes) : 15
        let loadedTargetMode = TargetMode(rawValue: defaults.string(forKey: Keys.targetMode) ?? "") ?? .auto
        let loadedManualTarget = defaults.integer(forKey: Keys.manualTargetMl) > 0 ? defaults.integer(forKey: Keys.manualTargetMl) : 2300
        self.targetMode = loadedTargetMode
        self.manualTargetMl = loadedManualTarget
        self.manualTargetInput = String(loadedManualTarget)

        let targetMl = loadedTargetMode == .manual ? loadedManualTarget : GoalCalculator.dailyTargetMl(profile: profile)
        self.store = HydrationAppStore(profile: profile, targetMl: targetMl)
        self.workSchedule = schedule

        self.weightKg = profile.weightKg
        self.age = profile.age
        self.cupCapacityMl = profile.cupCapacityMl
        self.weightInput = String(profile.weightKg)
        self.ageInput = String(profile.age)
        self.cupCapacityInput = String(profile.cupCapacityMl)
        self.gender = profile.gender
        self.workStartTime = Self.makeTime(hour: schedule.workStartHour, minute: schedule.workStartMinute)
        self.workEndTime = Self.makeTime(hour: schedule.workEndHour, minute: schedule.workEndMinute)
        self.lunchStartTime = Self.makeTime(hour: schedule.lunchStartHour, minute: schedule.lunchStartMinute)
        self.lunchEndTime = Self.makeTime(hour: schedule.lunchEndHour, minute: schedule.lunchEndMinute)
        self.actionMessage = nil

        notificationActionObserver = NotificationCenter.default.addObserver(
            forName: NotificationManager.userActionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            guard let action = notification.userInfo?["action"] as? String else { return }
            Task { @MainActor in
                if action == NotificationManager.actionHalfCup {
                    self.drinkHalfCup()
                    self.showMessage("已记录：喝了半杯水")
                } else if action == NotificationManager.actionOneCup {
                    self.drinkOneCup()
                    self.showMessage("已记录：喝了一杯水")
                }
            }
        }

        startReminderLoop()
    }

    var progressText: String {
        "\(store.state.consumedMl) / \(store.state.targetMl) ml"
    }

    var cupText: String {
        "杯中约 \(store.state.cupRemainingMl) ml"
    }

    var dailyPlanText: String {
        let summary = WorkdayPlanSummaryCalculator.summary(
            targetMl: store.state.targetMl,
            cupCapacityMl: max(store.state.cupCapacityMl, 1)
        )
        return "今日建议：\(store.state.targetMl) ml（约\(summary.cupsToDrink)杯）"
    }

    var nextReminderText: String {
        guard hasCompletedOnboarding else {
            return "预计下次提醒喝水时间：完成设置后显示"
        }
        guard isWorking else {
            return "预计下次提醒喝水时间：下班后不提醒"
        }

        let now = Date()
        let active = ScheduleEvaluator.isReminderActive(now: now, schedule: workSchedule)
        guard active else {
            return "预计下次提醒喝水时间：当前时段不提醒"
        }

        let remaining = remainingActiveMinutes(from: now, schedule: workSchedule)
        guard let interval = ReminderScheduler.nextReminderIntervalMinutes(
            consumedMl: store.state.consumedMl,
            targetMl: store.state.targetMl,
            remainingActiveMinutes: remaining
        ) else {
            return "预计下次提醒喝水时间：今日目标已完成"
        }

        let nextDate = Calendar.current.date(byAdding: .minute, value: interval, to: now) ?? now
        return "预计下次提醒喝水时间：\(Self.timeFormatter.string(from: nextDate))"
    }

    var workStatusText: String {
        if !hasCompletedOnboarding {
            return "请先完成首次设置"
        }
        return isWorking ? "上班中：会按规则提醒" : "已下班：不会提醒"
    }

    var animalText: String {
        switch currentMood {
        case .happy:
            return "小水獭状态很棒，节奏超前"
        case .okay:
            return "小水獭状态稳定，继续保持"
        case .thirsty:
            return "小水獭提醒你该补点水了"
        }
    }

    var animalSymbol: String {
        switch currentMood {
        case .happy:
            return "face.smiling.inverse"
        case .okay:
            return "face.dashed"
        case .thirsty:
            return "drop.triangle"
        }
    }

    func drinkHalfCup() {
        guard hasCompletedOnboarding, isWorking else { return }
        store.drinkHalfCup()
        evaluateReminder(now: Date())
        objectWillChange.send()
    }

    func drinkOneCup() {
        guard hasCompletedOnboarding, isWorking else { return }
        store.drinkOneCup()
        evaluateReminder(now: Date())
        objectWillChange.send()
    }

    func snooze() {
        guard hasCompletedOnboarding, isWorking else { return }
        store.snooze(minutes: snoozeMinutes)
        objectWillChange.send()
    }

    func sendTestNotification() {
        Task { @MainActor in
            let result = await notificationManager.sendTestNotification()
            switch result {
            case .sent:
                showMessage("测试提示已发送，请查看系统通知中心")
            case .denied:
                showMessage("系统通知权限未开启，请到系统设置中允许通知")
            case .failed:
                showMessage("测试提示发送失败，请稍后再试")
            }
        }
    }

    func startWorkday() {
        guard hasCompletedOnboarding else { return }
        isWorking = true
        store.startWorkday()
        lastNotificationAt = nil
        lastReminderKind = nil
        UserDefaults.standard.set(true, forKey: Keys.isWorking)
        evaluateReminder(now: Date())
        objectWillChange.send()
    }

    func endWorkday() {
        isWorking = false
        UserDefaults.standard.set(false, forKey: Keys.isWorking)
        objectWillChange.send()
    }

    func applySettings(markOnboardingComplete: Bool = true) {
        applyNumericInputs()
        weightKg = max(30, weightKg)
        age = max(10, age)
        cupCapacityMl = max(100, cupCapacityMl)
        if let value = Int(manualTargetInput.trimmingCharacters(in: .whitespacesAndNewlines)), value > 0 {
            manualTargetMl = value
        }
        manualTargetMl = max(1000, manualTargetMl)
        syncNumericInputs()
        manualTargetInput = String(manualTargetMl)

        let profile = UserProfile(
            weightKg: weightKg,
            gender: gender,
            age: age,
            cupCapacityMl: cupCapacityMl
        )
        let target = targetMode == .manual ? manualTargetMl : GoalCalculator.dailyTargetMl(profile: profile)
        store.reconfigure(profile: profile, targetMl: target)
        workSchedule = WorkSchedule(
            workStartHour: Self.hour(from: workStartTime),
            workStartMinute: Self.minute(from: workStartTime),
            workEndHour: Self.hour(from: workEndTime),
            workEndMinute: Self.minute(from: workEndTime),
            lunchStartHour: Self.hour(from: lunchStartTime),
            lunchStartMinute: Self.minute(from: lunchStartTime),
            lunchEndHour: Self.hour(from: lunchEndTime),
            lunchEndMinute: Self.minute(from: lunchEndTime)
        )

        if markOnboardingComplete {
            hasCompletedOnboarding = true
            UserDefaults.standard.set(true, forKey: Keys.hasCompletedOnboarding)
        }

        saveSettings()
        evaluateReminder(now: Date())
        showMessage("保存设置成功")
        objectWillChange.send()
    }

    func resetSettings() {
        let defaults = UserDefaults.standard
        let keys = [
            Keys.weightKg, Keys.age, Keys.cupCapacityMl, Keys.gender,
            Keys.workStartHour, Keys.workStartMinute, Keys.workEndHour, Keys.workEndMinute,
            Keys.lunchStartHour, Keys.lunchStartMinute, Keys.lunchEndHour, Keys.lunchEndMinute,
            Keys.snoozeMinutes, Keys.hasCompletedOnboarding, Keys.isWorking
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }

        weightKg = Self.defaultProfile.weightKg
        age = Self.defaultProfile.age
        cupCapacityMl = Self.defaultProfile.cupCapacityMl
        syncNumericInputs()
        gender = Self.defaultProfile.gender
        snoozeMinutes = 15
        targetMode = .auto
        manualTargetMl = 2300
        manualTargetInput = "2300"

        workStartTime = Self.makeTime(hour: Self.defaultSchedule.workStartHour, minute: Self.defaultSchedule.workStartMinute)
        workEndTime = Self.makeTime(hour: Self.defaultSchedule.workEndHour, minute: Self.defaultSchedule.workEndMinute)
        lunchStartTime = Self.makeTime(hour: Self.defaultSchedule.lunchStartHour, minute: Self.defaultSchedule.lunchStartMinute)
        lunchEndTime = Self.makeTime(hour: Self.defaultSchedule.lunchEndHour, minute: Self.defaultSchedule.lunchEndMinute)

        hasCompletedOnboarding = false
        isWorking = false
        lastNotificationAt = nil
        lastReminderKind = nil

        let target = GoalCalculator.dailyTargetMl(profile: Self.defaultProfile)
        store.reconfigure(profile: Self.defaultProfile, targetMl: target)
        workSchedule = Self.defaultSchedule
        showMessage("重置设置成功")
        objectWillChange.send()
    }

    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(weightKg, forKey: Keys.weightKg)
        defaults.set(age, forKey: Keys.age)
        defaults.set(cupCapacityMl, forKey: Keys.cupCapacityMl)
        defaults.set(gender.rawValue, forKey: Keys.gender)
        defaults.set(Self.hour(from: workStartTime), forKey: Keys.workStartHour)
        defaults.set(Self.minute(from: workStartTime), forKey: Keys.workStartMinute)
        defaults.set(Self.hour(from: workEndTime), forKey: Keys.workEndHour)
        defaults.set(Self.minute(from: workEndTime), forKey: Keys.workEndMinute)
        defaults.set(Self.hour(from: lunchStartTime), forKey: Keys.lunchStartHour)
        defaults.set(Self.minute(from: lunchStartTime), forKey: Keys.lunchStartMinute)
        defaults.set(Self.hour(from: lunchEndTime), forKey: Keys.lunchEndHour)
        defaults.set(Self.minute(from: lunchEndTime), forKey: Keys.lunchEndMinute)
        defaults.set(snoozeMinutes, forKey: Keys.snoozeMinutes)
        defaults.set(targetMode.rawValue, forKey: Keys.targetMode)
        defaults.set(manualTargetMl, forKey: Keys.manualTargetMl)
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
        guard hasCompletedOnboarding, isWorking else {
            return
        }

        let active = ScheduleEvaluator.isReminderActive(now: now, schedule: workSchedule)
        let decision = NotificationDecision.nextReminder(
            state: store.state,
            isInReminderWindow: active
        )

        guard let reminder = decision else {
            return
        }

        if shouldNotify(now: now, reminder: reminder) {
            Task { @MainActor in
                _ = await notificationManager.send(reminder: reminder)
            }
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

    private static func makeTime(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
    }

    private static func hour(from date: Date) -> Int {
        Calendar.current.component(.hour, from: date)
    }

    private static func minute(from date: Date) -> Int {
        Calendar.current.component(.minute, from: date)
    }

    private var currentMood: AnimalMood {
        guard hasCompletedOnboarding else { return .okay }
        guard isWorking else { return .okay }

        let now = Date()
        let expected = expectedProgress(at: now)
        let actual = store.progress

        if actual >= min(1.0, expected + 0.15) || actual >= 0.75 {
            return .happy
        }
        if actual + 0.10 >= expected {
            return .okay
        }
        return .thirsty
    }

    private func showMessage(_ message: String) {
        actionMessage = message
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if actionMessage == message {
                actionMessage = nil
            }
        }
    }

    private func applyNumericInputs() {
        if let value = Int(weightInput.trimmingCharacters(in: .whitespacesAndNewlines)), value > 0 {
            weightKg = value
        }
        if let value = Int(ageInput.trimmingCharacters(in: .whitespacesAndNewlines)), value > 0 {
            age = value
        }
        if let value = Int(cupCapacityInput.trimmingCharacters(in: .whitespacesAndNewlines)), value > 0 {
            cupCapacityMl = value
        }
    }

    private func syncNumericInputs() {
        weightInput = String(weightKg)
        ageInput = String(age)
        cupCapacityInput = String(cupCapacityMl)
    }

    private func remainingActiveMinutes(from now: Date, schedule: WorkSchedule) -> Int {
        let current = Self.hour(from: now) * 60 + Self.minute(from: now)
        let workStart = schedule.workStartHour * 60 + schedule.workStartMinute
        let workEnd = schedule.workEndHour * 60 + schedule.workEndMinute
        let lunchStart = schedule.lunchStartHour * 60 + schedule.lunchStartMinute
        let lunchEnd = schedule.lunchEndHour * 60 + schedule.lunchEndMinute

        let effectiveStart = max(current, workStart)
        guard effectiveStart < workEnd else { return 0 }
        var minutes = workEnd - effectiveStart

        let overlapStart = max(effectiveStart, lunchStart)
        let overlapEnd = min(workEnd, lunchEnd)
        if overlapEnd > overlapStart {
            minutes -= (overlapEnd - overlapStart)
        }
        return max(0, minutes)
    }

    private func expectedProgress(at now: Date) -> Double {
        let total = totalActiveMinutes(schedule: workSchedule)
        guard total > 0 else { return 0 }
        let elapsed = elapsedActiveMinutes(from: now, schedule: workSchedule)
        return min(1.0, max(0, Double(elapsed) / Double(total)))
    }

    private func totalActiveMinutes(schedule: WorkSchedule) -> Int {
        let workStart = schedule.workStartHour * 60 + schedule.workStartMinute
        let workEnd = schedule.workEndHour * 60 + schedule.workEndMinute
        let lunchStart = schedule.lunchStartHour * 60 + schedule.lunchStartMinute
        let lunchEnd = schedule.lunchEndHour * 60 + schedule.lunchEndMinute
        let total = max(0, workEnd - workStart)
        let lunch = max(0, min(workEnd, lunchEnd) - max(workStart, lunchStart))
        return max(0, total - lunch)
    }

    private func elapsedActiveMinutes(from now: Date, schedule: WorkSchedule) -> Int {
        let current = Self.hour(from: now) * 60 + Self.minute(from: now)
        let workStart = schedule.workStartHour * 60 + schedule.workStartMinute
        let workEnd = schedule.workEndHour * 60 + schedule.workEndMinute
        let lunchStart = schedule.lunchStartHour * 60 + schedule.lunchStartMinute
        let lunchEnd = schedule.lunchEndHour * 60 + schedule.lunchEndMinute

        if current <= workStart { return 0 }
        let end = min(current, workEnd)
        var elapsed = max(0, end - workStart)
        let lunchOverlap = max(0, min(end, lunchEnd) - max(workStart, lunchStart))
        elapsed -= lunchOverlap
        return max(0, elapsed)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
