import Foundation

public enum Gender: String, Codable, CaseIterable, Sendable {
    case female
    case male
}

public struct UserProfile: Codable, Sendable {
    public let weightKg: Int
    public let gender: Gender
    public let age: Int
    public let cupCapacityMl: Int

    public init(weightKg: Int, gender: Gender, age: Int, cupCapacityMl: Int) {
        self.weightKg = weightKg
        self.gender = gender
        self.age = age
        self.cupCapacityMl = cupCapacityMl
    }
}

public struct WorkSchedule: Codable, Sendable {
    public let workStartHour: Int
    public let workStartMinute: Int
    public let workEndHour: Int
    public let workEndMinute: Int
    public let lunchStartHour: Int
    public let lunchStartMinute: Int
    public let lunchEndHour: Int
    public let lunchEndMinute: Int

    public init(
        workStartHour: Int,
        workStartMinute: Int,
        workEndHour: Int,
        workEndMinute: Int,
        lunchStartHour: Int,
        lunchStartMinute: Int,
        lunchEndHour: Int,
        lunchEndMinute: Int
    ) {
        self.workStartHour = workStartHour
        self.workStartMinute = workStartMinute
        self.workEndHour = workEndHour
        self.workEndMinute = workEndMinute
        self.lunchStartHour = lunchStartHour
        self.lunchStartMinute = lunchStartMinute
        self.lunchEndHour = lunchEndHour
        self.lunchEndMinute = lunchEndMinute
    }
}
