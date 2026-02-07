import Testing
@testable import HydrationAssistantDomain

@Test func refillReminderHasHigherPriorityThanDrinkReminder() {
    let state = DailyHydrationState(targetMl: 2000, consumedMl: 500, cupCapacityMl: 500, cupRemainingMl: 50)

    let decision = NotificationDecision.nextReminder(
        state: state,
        isInReminderWindow: true,
        refillThreshold: 0.2
    )

    #expect(decision == .refill)
}

@Test func drinkReminderWhenInWindowAndNotAtGoal() {
    let state = DailyHydrationState(targetMl: 2000, consumedMl: 800, cupCapacityMl: 500, cupRemainingMl: 300)

    let decision = NotificationDecision.nextReminder(
        state: state,
        isInReminderWindow: true,
        refillThreshold: 0.2
    )

    #expect(decision == .drink)
}

@Test func noReminderOutsideWindowOrAfterGoal() {
    let outside = DailyHydrationState(targetMl: 2000, consumedMl: 800, cupCapacityMl: 500, cupRemainingMl: 300)
    let done = DailyHydrationState(targetMl: 2000, consumedMl: 2000, cupCapacityMl: 500, cupRemainingMl: 300)

    #expect(NotificationDecision.nextReminder(state: outside, isInReminderWindow: false, refillThreshold: 0.2) == nil)
    #expect(NotificationDecision.nextReminder(state: done, isInReminderWindow: true, refillThreshold: 0.2) == nil)
}
