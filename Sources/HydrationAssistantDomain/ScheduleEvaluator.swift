import Foundation

public enum ScheduleEvaluator {
    public static func isReminderActive(now: Date, schedule: WorkSchedule, calendar: Calendar = .current) -> Bool {
        let minute = minuteOfDay(for: now, calendar: calendar)
        let workStart = schedule.workStartHour * 60 + schedule.workStartMinute
        let workEnd = schedule.workEndHour * 60 + schedule.workEndMinute
        let lunchStart = schedule.lunchStartHour * 60 + schedule.lunchStartMinute
        let lunchEnd = schedule.lunchEndHour * 60 + schedule.lunchEndMinute

        guard minute >= workStart, minute <= workEnd else {
            return false
        }

        if minute >= lunchStart, minute < lunchEnd {
            return false
        }

        return true
    }

    private static func minuteOfDay(for date: Date, calendar: Calendar) -> Int {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }
}
