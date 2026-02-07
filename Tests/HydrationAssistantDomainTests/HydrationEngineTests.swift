import Testing
@testable import HydrationAssistantDomain

@Test func drinkingUpdatesConsumedAndCupRemaining() {
    var state = DailyHydrationState(targetMl: 2400, consumedMl: 0, cupCapacityMl: 500, cupRemainingMl: 500)

    HydrationEngine.recordDrink(amountMl: 250, state: &state)

    #expect(state.consumedMl == 250)
    #expect(state.cupRemainingMl == 250)
    #expect(!state.isGoalReached)
}

@Test func refillResetsCupRemainingToCapacity() {
    var state = DailyHydrationState(targetMl: 2400, consumedMl: 500, cupCapacityMl: 500, cupRemainingMl: 80)

    HydrationEngine.refillCup(state: &state)

    #expect(state.cupRemainingMl == 500)
}

@Test func refillReminderTriggersUnderThreshold() {
    let state = DailyHydrationState(targetMl: 2400, consumedMl: 500, cupCapacityMl: 500, cupRemainingMl: 90)

    #expect(HydrationEngine.shouldTriggerRefillReminder(state: state, threshold: 0.2))
}

@Test func goalReachedWhenConsumedExceedsTarget() {
    var state = DailyHydrationState(targetMl: 800, consumedMl: 700, cupCapacityMl: 500, cupRemainingMl: 200)

    HydrationEngine.recordDrink(amountMl: 150, state: &state)

    #expect(state.isGoalReached)
}
