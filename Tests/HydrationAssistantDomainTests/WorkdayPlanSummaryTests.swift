import Testing
@testable import HydrationAssistantDomain

@Test func summaryCalculatesCupAndRefillCount() {
    let summary = WorkdayPlanSummaryCalculator.summary(targetMl: 2310, cupCapacityMl: 500)

    #expect(summary.cupsToDrink == 5)
    #expect(summary.refillTimes == 4)
}

@Test func summaryHandlesSingleCupTarget() {
    let summary = WorkdayPlanSummaryCalculator.summary(targetMl: 300, cupCapacityMl: 500)

    #expect(summary.cupsToDrink == 1)
    #expect(summary.refillTimes == 0)
}
