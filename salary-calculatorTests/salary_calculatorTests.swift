//
//  salary_calculatorTests.swift
//  salary-calculatorTests
//

import Testing
import Foundation
@testable import salary_calculator

struct salary_calculatorTests {

    /// 构造一份确定的测试配置：月薪、9:00-18:00、午休 12:00-13:00、周一到周五。
    private func makeConfig(monthlySalary: Double = 22000) -> SalaryConfig {
        SalaryConfig(
            monthlySalary: monthlySalary,
            workStartTime: SalaryConfig.time(hour: 9, minute: 0),
            workEndTime: SalaryConfig.time(hour: 18, minute: 0),
            lunchStartTime: SalaryConfig.time(hour: 12, minute: 0),
            lunchEndTime: SalaryConfig.time(hour: 13, minute: 0),
            workDays: [2, 3, 4, 5, 6]
        )
    }

    /// 找到指定星期几的一个日期，并设置到具体时分。
    private func date(weekday: Int, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var date = calendar.startOfDay(for: Date())
        // 向前找到目标 weekday
        for _ in 0..<14 {
            if calendar.component(.weekday, from: date) == weekday { break }
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
    }

    // MARK: - 每日工作秒数

    @Test func dailyWorkSeconds_扣除午休() {
        let config = makeConfig()
        // 9:00-18:00 = 9h，扣 1h 午休 = 8h = 28800 秒
        #expect(config.dailyWorkSeconds == 28800)
    }

    @Test func dailyWorkSeconds_无午休() {
        let config = SalaryConfig(
            workStartTime: SalaryConfig.time(hour: 9, minute: 0),
            workEndTime: SalaryConfig.time(hour: 17, minute: 0),
            lunchStartTime: nil,
            lunchEndTime: nil,
            workDays: [2, 3, 4, 5, 6]
        )
        // 9:00-17:00 = 8h = 28800 秒
        #expect(config.dailyWorkSeconds == 28800)
    }

    // MARK: - 每秒工资非法配置保护

    @Test func salaryPerSecond_无工作日时为零() {
        let config = makeConfig()
        config.workDays = []
        #expect(config.salaryPerSecond == 0)
    }

    @Test func salaryPerSecond_为正且有限() {
        let config = makeConfig()
        #expect(config.salaryPerSecond > 0)
        #expect(config.salaryPerSecond.isFinite)
    }

    // MARK: - 核心：今日收入随时间递增（会跳动）

    @Test func 今日收入随时间递增() {
        let config = makeConfig()
        let calculator = SalaryCalculator(config: config)

        let at10 = date(weekday: 3, hour: 10, minute: 0) // 周二 10:00
        let at11 = date(weekday: 3, hour: 11, minute: 0) // 周二 11:00

        let earn10 = calculator.todayEarnings(asOf: at10)
        let earn11 = calculator.todayEarnings(asOf: at11)

        #expect(earn10 > 0)
        #expect(earn11 > earn10) // 一小时后赚得更多 —— 证明会跳动
    }

    @Test func 上班前收入为零() {
        let config = makeConfig()
        let calculator = SalaryCalculator(config: config)
        let at8 = date(weekday: 3, hour: 8, minute: 0) // 上班前
        #expect(calculator.todayEarnings(asOf: at8) == 0)
    }

    @Test func 下班后为当日满额() {
        let config = makeConfig()
        let calculator = SalaryCalculator(config: config)
        let at20 = date(weekday: 3, hour: 20, minute: 0) // 下班后
        let expected = config.salaryPerSecond * config.dailyWorkSeconds
        let actual = calculator.todayEarnings(asOf: at20)
        #expect(abs(actual - expected) < 0.01)
    }

    @Test func 午休期间不增长() {
        let config = makeConfig()
        let calculator = SalaryCalculator(config: config)
        let at1230 = date(weekday: 3, hour: 12, minute: 30) // 午休中
        let at1300 = date(weekday: 3, hour: 13, minute: 0)  // 午休结束
        // 午休期间不计薪，两个时刻收入应相同
        #expect(abs(calculator.todayEarnings(asOf: at1230) - calculator.todayEarnings(asOf: at1300)) < 0.01)
    }

    @Test func 休息日今日收入为零() {
        let config = makeConfig()
        let calculator = SalaryCalculator(config: config)
        let sunday = date(weekday: 1, hour: 14, minute: 0) // 周日
        #expect(calculator.todayEarnings(asOf: sunday) == 0)
    }

    // MARK: - 调休补班

    @Test func 调休补班日计薪() {
        let config = makeConfig()
        let sunday = date(weekday: 1, hour: 14, minute: 0) // 周日
        let makeup = HolidayConfig(date: sunday, name: "调休补班", isWorkday: true)
        let calculator = SalaryCalculator(config: config, holidays: [makeup])
        #expect(calculator.todayEarnings(asOf: sunday) > 0) // 补班日要上班，计薪
    }

    @Test func 法定节假日不计薪() {
        let config = makeConfig()
        let workday = date(weekday: 3, hour: 14, minute: 0) // 周二
        let holiday = HolidayConfig(date: workday, name: "国庆节", isWorkday: false)
        let calculator = SalaryCalculator(config: config, holidays: [holiday])
        #expect(calculator.todayEarnings(asOf: workday) == 0) // 工作日被设为节假日，不计薪
    }

    // MARK: - 时段判断

    @Test func 时段判断_各时段正确() {
        let config = makeConfig()
        let calculator = SalaryCalculator(config: config)

        #expect(calculator.phase(asOf: date(weekday: 3, hour: 8, minute: 0)) == .beforeWork)
        #expect(calculator.phase(asOf: date(weekday: 3, hour: 10, minute: 0)) == .working)
        #expect(calculator.phase(asOf: date(weekday: 3, hour: 12, minute: 30)) == .lunchBreak)
        #expect(calculator.phase(asOf: date(weekday: 3, hour: 20, minute: 0)) == .afterWork)
        #expect(calculator.phase(asOf: date(weekday: 1, hour: 14, minute: 0)) == .dayOff)
    }
}
