import Foundation
import SwiftData

/// 工资配置（V1 极简版）。
///
/// 只保留实时计薪必需的字段：月薪、上下班时间、午休、工作日。
/// 加班 / 节假日倍率等高级功能留到后续版本。
@Model
final class SalaryConfig {
    /// 月薪（元）
    var monthlySalary: Double

    /// 上下班时间（只取其时分部分）
    var workStartTime: Date
    var workEndTime: Date

    /// 午休时间（可选；为 nil 表示不午休）
    var lunchStartTime: Date?
    var lunchEndTime: Date?

    /// 工作日（Calendar.weekday：1=周日 … 7=周六）
    var workDays: Set<Int>

    var createdAt: Date
    var updatedAt: Date

    init(
        monthlySalary: Double = 10000,
        workStartTime: Date = SalaryConfig.time(hour: 9, minute: 0),
        workEndTime: Date = SalaryConfig.time(hour: 18, minute: 0),
        lunchStartTime: Date? = SalaryConfig.time(hour: 12, minute: 0),
        lunchEndTime: Date? = SalaryConfig.time(hour: 13, minute: 0),
        workDays: Set<Int> = [2, 3, 4, 5, 6] // 默认周一到周五
    ) {
        self.monthlySalary = monthlySalary
        self.workStartTime = workStartTime
        self.workEndTime = workEndTime
        self.lunchStartTime = lunchStartTime
        self.lunchEndTime = lunchEndTime
        self.workDays = workDays
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func update(
        monthlySalary: Double? = nil,
        workStartTime: Date? = nil,
        workEndTime: Date? = nil,
        lunchStartTime: Date?? = nil,
        lunchEndTime: Date?? = nil,
        workDays: Set<Int>? = nil
    ) {
        if let monthlySalary { self.monthlySalary = monthlySalary }
        if let workStartTime { self.workStartTime = workStartTime }
        if let workEndTime { self.workEndTime = workEndTime }
        if let lunchStartTime { self.lunchStartTime = lunchStartTime }
        if let lunchEndTime { self.lunchEndTime = lunchEndTime }
        if let workDays { self.workDays = workDays }
        self.updatedAt = Date()
    }

    /// 每日工作秒数（已扣除午休）。
    var dailyWorkSeconds: TimeInterval {
        let calendar = Calendar.current
        let start = secondsOfDay(workStartTime, calendar)
        let end = secondsOfDay(workEndTime, calendar)
        var total = max(0, end - start)

        if let lunchStartTime, let lunchEndTime {
            let lunchStart = secondsOfDay(lunchStartTime, calendar)
            let lunchEnd = secondsOfDay(lunchEndTime, calendar)
            total -= max(0, lunchEnd - lunchStart)
        }
        return max(0, total)
    }

    /// 当月工作日数（按星期几统计，不含节假日调整）。
    var workDaysInCurrentMonth: Int {
        Calendar.current.workDayCount(in: Date(), workDays: workDays)
    }

    /// 每秒工资。配置非法时返回 0，避免 NaN / 无穷大。
    var salaryPerSecond: Double {
        let workdays = workDaysInCurrentMonth
        let seconds = dailyWorkSeconds
        guard workdays > 0, seconds > 0 else { return 0 }
        return monthlySalary / Double(workdays) / seconds
    }

    // MARK: - Helpers

    private func secondsOfDay(_ date: Date, _ calendar: Calendar) -> TimeInterval {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        return TimeInterval((comps.hour ?? 0) * 3600 + (comps.minute ?? 0) * 60)
    }

    static func time(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
    }
}

extension Calendar {
    /// 统计某个月里有多少个工作日（按星期几）。
    func workDayCount(in monthDate: Date, workDays: Set<Int>) -> Int {
        guard let range = range(of: .day, in: .month, for: monthDate) else { return 0 }
        let year = component(.year, from: monthDate)
        let month = component(.month, from: monthDate)

        var count = 0
        for day in range {
            if let date = date(from: DateComponents(year: year, month: month, day: day)),
               workDays.contains(component(.weekday, from: date)) {
                count += 1
            }
        }
        return count
    }
}
