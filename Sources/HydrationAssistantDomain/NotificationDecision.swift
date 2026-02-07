import Foundation

public enum ReminderKind: String, Sendable {
    case drink
}

public enum NotificationDecision {
    public static func nextReminder(
        state: DailyHydrationState,
        isInReminderWindow: Bool
    ) -> ReminderKind? {
        guard isInReminderWindow, !state.isGoalReached else {
            return nil
        }
        return .drink
    }
}
