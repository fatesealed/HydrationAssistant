import Testing
@testable import HydrationAssistantDomain

@Test func intervalCalculatedFromRemainingTargetAndTime() {
    let interval = ReminderScheduler.nextReminderIntervalMinutes(
        consumedMl: 1200,
        targetMl: 2400,
        remainingActiveMinutes: 240
    )

    #expect(interval == 40)
}

@Test func noReminderWhenGoalReached() {
    let interval = ReminderScheduler.nextReminderIntervalMinutes(
        consumedMl: 2400,
        targetMl: 2400,
        remainingActiveMinutes: 240
    )

    #expect(interval == nil)
}

@Test func snoozeReturnsFixedDelay() {
    #expect(ReminderScheduler.snoozedIntervalMinutes(defaultMinutes: 15) == 15)
}
