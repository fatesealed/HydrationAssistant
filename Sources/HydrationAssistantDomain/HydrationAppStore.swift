import Foundation

public enum AnimalMood: String, Sendable {
    case thirsty
    case okay
    case happy
}

public final class HydrationAppStore: @unchecked Sendable {
    private static let halfCupMaxMl = 300
    private static let oneCupMaxMl = 500

    public private(set) var profile: UserProfile
    public private(set) var state: DailyHydrationState
    public private(set) var snoozedMinutes: Int?

    public init(profile: UserProfile, targetMl: Int) {
        self.profile = profile
        self.state = DailyHydrationState(
            targetMl: targetMl,
            consumedMl: 0,
            cupCapacityMl: profile.cupCapacityMl,
            cupRemainingMl: profile.cupCapacityMl
        )
        self.snoozedMinutes = nil
    }

    public var progress: Double {
        guard state.targetMl > 0 else { return 0 }
        return min(1, Double(state.consumedMl) / Double(state.targetMl))
    }

    public var animalMood: AnimalMood {
        if progress >= 1 {
            return .happy
        }
        if progress >= 0.45 {
            return .okay
        }
        return .thirsty
    }

    public func drinkHalfCup() {
        let amount = min(max(1, profile.cupCapacityMl / 2), Self.halfCupMaxMl)
        HydrationEngine.recordDrink(amountMl: amount, state: &state)
        snoozedMinutes = nil
    }

    public func drinkOneCup() {
        let amount = min(profile.cupCapacityMl, Self.oneCupMaxMl)
        HydrationEngine.recordDrink(amountMl: amount, state: &state)
        snoozedMinutes = nil
    }

    public func refillCup() {
        HydrationEngine.refillCup(state: &state)
    }

    public func snooze(minutes: Int) {
        snoozedMinutes = ReminderScheduler.snoozedIntervalMinutes(defaultMinutes: minutes)
    }

    public func reconfigure(profile: UserProfile, targetMl: Int) {
        self.profile = profile
        self.state = DailyHydrationState(
            targetMl: targetMl,
            consumedMl: 0,
            cupCapacityMl: profile.cupCapacityMl,
            cupRemainingMl: profile.cupCapacityMl
        )
        self.snoozedMinutes = nil
    }

    public func startWorkday() {
        self.state = DailyHydrationState(
            targetMl: state.targetMl,
            consumedMl: 0,
            cupCapacityMl: profile.cupCapacityMl,
            cupRemainingMl: profile.cupCapacityMl
        )
        self.snoozedMinutes = nil
    }
}
