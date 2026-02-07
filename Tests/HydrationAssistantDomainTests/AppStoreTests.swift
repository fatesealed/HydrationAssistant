import Testing
@testable import HydrationAssistantDomain

@Test func halfCupActionUpdatesState() {
    let profile = UserProfile(weightKg: 60, gender: .female, age: 28, cupCapacityMl: 500)
    let store = HydrationAppStore(profile: profile, targetMl: 2000)

    store.drinkHalfCup()

    #expect(store.state.consumedMl == 250)
    #expect(store.state.cupRemainingMl == 250)
}

@Test func refillActionResetsCupToCapacity() {
    let profile = UserProfile(weightKg: 60, gender: .female, age: 28, cupCapacityMl: 500)
    let store = HydrationAppStore(profile: profile, targetMl: 2000)

    store.drinkOneCup()
    store.refillCup()

    #expect(store.state.cupRemainingMl == 500)
}

@Test func animalMoodChangesWithProgress() {
    let profile = UserProfile(weightKg: 60, gender: .female, age: 28, cupCapacityMl: 500)
    let store = HydrationAppStore(profile: profile, targetMl: 1000)

    #expect(store.animalMood == .thirsty)
    store.drinkOneCup()
    #expect(store.animalMood == .okay)
    store.drinkOneCup()
    #expect(store.animalMood == .happy)
}
@Test func reconfigureProfileUpdatesTargetAndCupCapacity() {
    let profile = UserProfile(weightKg: 60, gender: .female, age: 28, cupCapacityMl: 500)
    let store = HydrationAppStore(profile: profile, targetMl: 2000)

    let newProfile = UserProfile(weightKg: 80, gender: .male, age: 35, cupCapacityMl: 700)
    store.reconfigure(profile: newProfile, targetMl: 2800)

    #expect(store.state.targetMl == 2800)
    #expect(store.state.cupCapacityMl == 700)
    #expect(store.state.cupRemainingMl == 700)
}


@Test func startWorkdayResetsConsumedAndRefillsCup() {
    let profile = UserProfile(weightKg: 60, gender: .female, age: 28, cupCapacityMl: 500)
    let store = HydrationAppStore(profile: profile, targetMl: 2000)

    store.drinkOneCup()
    store.startWorkday()

    #expect(store.state.consumedMl == 0)
    #expect(store.state.cupRemainingMl == 500)
}
