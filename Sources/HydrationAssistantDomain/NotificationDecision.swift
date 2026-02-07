import Foundation

public enum ReminderKind: String, Sendable {
    case drink
    case refill
}

public enum NotificationDecision {
    public static func nextReminder(
        state: DailyHydrationState,
        isInReminderWindow: Bool,
        refillThreshold: Double
    ) -> ReminderKind? {
        guard isInReminderWindow, !state.isGoalReached else {
            return nil
        }

        if HydrationEngine.shouldTriggerRefillReminder(state: state, threshold: refillThreshold) {
            return .refill
        }

        return .drink
    }
}
