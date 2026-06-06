import Foundation

/// 实时工资计算引擎。
///
/// V1 模型（极简、可解释）：
/// - 工作日：在上班~下班之间按秒累计，扣除午休；下班后为当日满额。
/// - 非工作日：今日收入为 0（不工作不计薪）。
/// - 本月：今天之前已完成的工作日按日薪累计 + 今日实时。
/// - 年度：已完成整月按月薪累计 + 本月实时。
///
/// `holidays` 为空时（V1 默认），工作日判断退化为"按星期几"。
class SalaryCalculator {
    private let config: SalaryConfig
    private let holidays: [HolidayConfig]
    private let calendar = Calendar.current

    init(config: SalaryConfig, holidays: [HolidayConfig] = []) {
        self.config = config
        self.holidays = holidays
    }

    /// 判断某天是否为工作日。
    func isWorkday(_ date: Date) -> Bool {
        // 调休补班优先
        if HolidayConfig.isWorkday(date, holidays: holidays) { return true }
        // 法定节假日
        if HolidayConfig.isHoliday(date, holidays: holidays) { return false }
        // 常规工作日（按星期几）
        let weekday = calendar.component(.weekday, from: date)
        return config.workDays.contains(weekday)
    }

    /// 每秒工资。配置非法（无工作日 / 工作时长为 0）时返回 0，避免 NaN。
    var salaryPerSecond: Double {
        let value = config.salaryPerSecond
        return value.isFinite ? max(0, value) : 0
    }

    /// 今日收入（实时）。
    func todayEarnings(asOf now: Date = Date()) -> Double {
        guard isWorkday(now) else { return 0 }
        return workedSeconds(asOf: now) * salaryPerSecond
    }

    /// 当前所处的时段，用于界面展示准确的状态文案。
    enum DayPhase {
        case dayOff        // 休息日
        case beforeWork    // 上班前
        case working       // 工作中
        case lunchBreak    // 午休中
        case afterWork     // 已下班
    }

    /// 判断当前时段。
    func phase(asOf now: Date = Date()) -> DayPhase {
        guard isWorkday(now) else { return .dayOff }

        let start = setTime(config.workStartTime, on: now)
        let end = setTime(config.workEndTime, on: now)

        if now < start { return .beforeWork }
        if now >= end { return .afterWork }

        if let lunchStartTime = config.lunchStartTime,
           let lunchEndTime = config.lunchEndTime {
            let lunchStart = setTime(lunchStartTime, on: now)
            let lunchEnd = setTime(lunchEndTime, on: now)
            if now >= lunchStart && now < lunchEnd { return .lunchBreak }
        }

        return .working
    }

    /// 今日已工作秒数：考虑上下班时间，扣除午休。
    func workedSeconds(asOf now: Date = Date()) -> TimeInterval {        let start = setTime(config.workStartTime, on: now)
        let end = setTime(config.workEndTime, on: now)
        guard now > start else { return 0 }

        let capped = min(now, end)
        var seconds = capped.timeIntervalSince(start)

        // 扣除已经过去的午休时间
        if let lunchStartTime = config.lunchStartTime,
           let lunchEndTime = config.lunchEndTime {
            let lunchStart = setTime(lunchStartTime, on: now)
            let lunchEnd = setTime(lunchEndTime, on: now)
            if capped > lunchStart {
                let overlapEnd = min(capped, lunchEnd)
                seconds -= max(0, overlapEnd.timeIntervalSince(lunchStart))
            }
        }

        return max(0, seconds)
    }

    /// 本月收入：已完成工作日 + 今日实时。
    func monthEarnings(asOf now: Date = Date()) -> Double {
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let today = calendar.component(.day, from: now)

        // 日薪 = 每秒工资 × 每日工作秒数（与实时计算同源，保证一致）
        let dailySalary = salaryPerSecond * config.dailyWorkSeconds

        // 统计今天之前已完成的工作日
        var completedWorkdays = 0
        if today > 1 {
            for day in 1..<today {
                if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)),
                   isWorkday(date) {
                    completedWorkdays += 1
                }
            }
        }

        return dailySalary * Double(completedWorkdays) + todayEarnings(asOf: now)
    }

    /// 年度收入：已完成整月按月薪累计 + 本月实时。
    func yearEarnings(asOf now: Date = Date()) -> Double {
        let completedMonths = calendar.component(.month, from: now) - 1
        return config.monthlySalary * Double(completedMonths) + monthEarnings(asOf: now)
    }

    // MARK: - Helpers

    /// 把"只含时分"的时间映射到指定日期当天。
    private func setTime(_ time: Date, on day: Date) -> Date {
        let comps = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(
            bySettingHour: comps.hour ?? 0,
            minute: comps.minute ?? 0,
            second: 0,
            of: calendar.startOfDay(for: day)
        ) ?? day
    }
}
