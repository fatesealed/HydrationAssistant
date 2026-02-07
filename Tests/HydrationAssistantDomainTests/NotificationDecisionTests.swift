import Testing
@testable import HydrationAssistantDomain

@Test func lowCupStillUsesDrinkReminder() {
    let state = DailyHydrationState(targetMl: 2000, consumedMl: 500, cupCapacityMl: 500, cupRemainingMl: 50)

    let decision = NotificationDecision.nextReminder(
        state: state,
        isInReminderWindow: true
    )

    #expect(decision == .drink)
}

@Test func drinkReminderWhenInWindowAndNotAtGoal() {
    let state = DailyHydrationState(targetMl: 2000, consumedMl: 800, cupCapacityMl: 500, cupRemainingMl: 300)

    let decision = NotificationDecision.nextReminder(
        state: state,
        isInReminderWindow: true
    )

    #expect(decision == .drink)
}

@Test func noReminderOutsideWindowOrAfterGoal() {
    let outside = DailyHydrationState(targetMl: 2000, consumedMl: 800, cupCapacityMl: 500, cupRemainingMl: 300)
    let done = DailyHydrationState(targetMl: 2000, consumedMl: 2000, cupCapacityMl: 500, cupRemainingMl: 300)

    #expect(NotificationDecision.nextReminder(state: outside, isInReminderWindow: false) == nil)
    #expect(NotificationDecision.nextReminder(state: done, isInReminderWindow: true) == nil)
}
