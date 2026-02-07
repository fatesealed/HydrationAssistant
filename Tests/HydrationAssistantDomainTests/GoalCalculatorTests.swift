import Foundation
import Testing
@testable import HydrationAssistantDomain

@Test func dailyTargetUsesWeightFormula() {
    let profile = UserProfile(weightKg: 70, gender: .female, age: 30, cupCapacityMl: 500)
    let target = GoalCalculator.dailyTargetMl(profile: profile)
    #expect(target == 2310)
}

@Test func dailyTargetAppliesAgeAdjustmentForSeniors() {
    let profile = UserProfile(weightKg: 70, gender: .male, age: 70, cupCapacityMl: 500)
    let target = GoalCalculator.dailyTargetMl(profile: profile)
    #expect(target == 2132)
}

@Test func dailyTargetIsClampedToSafeRange() {
    let low = UserProfile(weightKg: 30, gender: .female, age: 20, cupCapacityMl: 350)
    let high = UserProfile(weightKg: 200, gender: .male, age: 25, cupCapacityMl: 1000)

    #expect(GoalCalculator.dailyTargetMl(profile: low) == 1500)
    #expect(GoalCalculator.dailyTargetMl(profile: high) == 4500)
}
