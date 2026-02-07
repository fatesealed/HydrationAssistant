import Foundation

public struct DailyHydrationState: Sendable {
    public let targetMl: Int
    public var consumedMl: Int
    public let cupCapacityMl: Int
    public var cupRemainingMl: Int

    public var isGoalReached: Bool {
        consumedMl >= targetMl
    }

    public init(targetMl: Int, consumedMl: Int, cupCapacityMl: Int, cupRemainingMl: Int) {
        self.targetMl = targetMl
        self.consumedMl = consumedMl
        self.cupCapacityMl = cupCapacityMl
        self.cupRemainingMl = cupRemainingMl
    }
}

public enum HydrationEngine {
    public static func recordDrink(amountMl: Int, state: inout DailyHydrationState) {
        guard amountMl > 0 else { return }
        state.consumedMl += amountMl
        state.cupRemainingMl = max(0, state.cupRemainingMl - amountMl)
    }

    public static func refillCup(state: inout DailyHydrationState) {
        state.cupRemainingMl = state.cupCapacityMl
    }

    public static func shouldTriggerRefillReminder(state: DailyHydrationState, threshold: Double) -> Bool {
        let thresholdMl = Int(Double(state.cupCapacityMl) * threshold)
        return state.cupRemainingMl <= thresholdMl
    }
}
