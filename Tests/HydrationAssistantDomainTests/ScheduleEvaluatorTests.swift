import Foundation
import Testing
@testable import HydrationAssistantDomain

@Test func remindersAreActiveWithinWorkHoursOutsideLunch() {
    let schedule = WorkSchedule(workStartHour: 9, workStartMinute: 0, workEndHour: 18, workEndMinute: 0, lunchStartHour: 12, lunchStartMinute: 0, lunchEndHour: 13, lunchEndMinute: 30)
    let now = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 7, hour: 10, minute: 15))!

    #expect(ScheduleEvaluator.isReminderActive(now: now, schedule: schedule))
}

@Test func remindersAreInactiveDuringLunch() {
    let schedule = WorkSchedule(workStartHour: 9, workStartMinute: 0, workEndHour: 18, workEndMinute: 0, lunchStartHour: 12, lunchStartMinute: 0, lunchEndHour: 13, lunchEndMinute: 30)
    let now = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 7, hour: 12, minute: 15))!

    #expect(!ScheduleEvaluator.isReminderActive(now: now, schedule: schedule))
}

@Test func remindersAreInactiveOutsideWorkHours() {
    let schedule = WorkSchedule(workStartHour: 9, workStartMinute: 0, workEndHour: 18, workEndMinute: 0, lunchStartHour: 12, lunchStartMinute: 0, lunchEndHour: 13, lunchEndMinute: 30)
    let beforeWork = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 7, hour: 8, minute: 59))!
    let afterWork = Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 7, hour: 18, minute: 1))!

    #expect(!ScheduleEvaluator.isReminderActive(now: beforeWork, schedule: schedule))
    #expect(!ScheduleEvaluator.isReminderActive(now: afterWork, schedule: schedule))
}
