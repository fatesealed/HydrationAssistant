import Foundation

public struct WorkdayPlanSummary: Sendable {
    public let cupsToDrink: Int
    public let refillTimes: Int

    public init(cupsToDrink: Int, refillTimes: Int) {
        self.cupsToDrink = cupsToDrink
        self.refillTimes = refillTimes
    }
}

public enum WorkdayPlanSummaryCalculator {
    public static func summary(targetMl: Int, cupCapacityMl: Int) -> WorkdayPlanSummary {
        guard targetMl > 0, cupCapacityMl > 0 else {
            return WorkdayPlanSummary(cupsToDrink: 0, refillTimes: 0)
        }
        let cups = Int(ceil(Double(targetMl) / Double(cupCapacityMl)))
        return WorkdayPlanSummary(cupsToDrink: cups, refillTimes: max(cups - 1, 0))
    }
}
