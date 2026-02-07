import Foundation

public enum ReminderScheduler {
    private static let defaultSipMl = 200
    private static let minIntervalMinutes = 15
    private static let maxIntervalMinutes = 120

    public static func nextReminderIntervalMinutes(
        consumedMl: Int,
        targetMl: Int,
        remainingActiveMinutes: Int
    ) -> Int? {
        let remainingMl = targetMl - consumedMl
        guard remainingMl > 0, remainingActiveMinutes > 0 else {
            return nil
        }

        let remindersNeeded = max(1, Int(ceil(Double(remainingMl) / Double(defaultSipMl))))
        let rawInterval = remainingActiveMinutes / remindersNeeded
        return min(max(rawInterval, minIntervalMinutes), maxIntervalMinutes)
    }

    public static func snoozedIntervalMinutes(defaultMinutes: Int) -> Int {
        max(defaultMinutes, minIntervalMinutes)
    }
}
