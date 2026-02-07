import Foundation

public enum GoalCalculator {
    private static let baseFactorMlPerKg = 33
    private static let maleAdjustmentMl = 122
    private static let seniorAdjustmentMl = -300
    private static let teenAdjustmentMl = -150
    private static let minTargetMl = 1500
    private static let maxTargetMl = 4500

    public static func dailyTargetMl(profile: UserProfile) -> Int {
        var target = profile.weightKg * baseFactorMlPerKg

        if profile.gender == .male {
            target += maleAdjustmentMl
        }

        if profile.age >= 65 {
            target += seniorAdjustmentMl
        } else if profile.age < 18 {
            target += teenAdjustmentMl
        }

        return min(max(target, minTargetMl), maxTargetMl)
    }
}
