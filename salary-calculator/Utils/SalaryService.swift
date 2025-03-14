import Foundation

class SalaryService {
    private let repository: SalaryConfigRepository
    private let holidayRepository: HolidayConfigRepository
    
    init(repository: SalaryConfigRepository, holidayRepository: HolidayConfigRepository) {
        self.repository = repository
        self.holidayRepository = holidayRepository
    }
    
    // 获取当前薪资配置
    func getCurrentConfig() throws -> SalaryConfig {
        let configs = try repository.fetch()
        return configs.first ?? SalaryConfig()
    }
    
    // 更新薪资配置
    func updateConfig(_ config: SalaryConfig) throws {
        try validateConfig(config)
        try repository.update(config)
    }
    
    // 计算指定日期的工资
    func calculateSalary(for date: Date) throws -> Double {
        let config = try getCurrentConfig()
        let holidays = try holidayRepository.fetch()
        
        // 判断是否为节假日
        if HolidayConfig.isHoliday(date, holidays: holidays) {
            let overtimeSeconds = config.calculateHolidayOvertimeSeconds(for: date)
            return config.salaryPerSecond * overtimeSeconds * config.holidayOvertimeRate
        }
        
        // 判断是否为工作日
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        if config.workDays.contains(weekday) || HolidayConfig.isWorkday(date, holidays: holidays) {
            // 计算正常工作时间工资
            let normalSalary = config.salaryPerSecond * config.dailyWorkSeconds
            
            // 计算加班工资
            let overtimeSeconds = config.calculateOvertimeSeconds(for: date)
            let overtimeSalary = config.salaryPerSecond * overtimeSeconds * config.overtimeRate
            
            return normalSalary + overtimeSalary
        }
        
        return 0
    }
    
    // 计算指定月份的总工资
    func calculateMonthlySalary(year: Int, month: Int) throws -> Double {
        let calendar = Calendar.current
        guard let startDate = calendar.date(from: DateComponents(year: year, month: month)),
              let range = calendar.range(of: .day, in: .month, for: startDate) else {
            throw AppError.validationError("无效的日期")
        }
        
        var totalSalary = 0.0
        for day in 1...range.count {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                totalSalary += try calculateSalary(for: date)
            }
        }
        
        return totalSalary
    }
    
    // 验证配置
    private func validateConfig(_ config: SalaryConfig) throws {
        guard config.monthlySalary > 0 else {
            throw AppError.validationError("月薪必须大于0")
        }
        
        guard !config.workDays.isEmpty else {
            throw AppError.validationError("必须设置工作日")
        }
        
        guard config.overtimeRate >= 1 else {
            throw AppError.validationError("加班工资倍率必须大于等于1")
        }
        
        guard config.holidayOvertimeRate >= 1 else {
            throw AppError.validationError("节假日工资倍率必须大于等于1")
        }
        
        // 验证时间范围
        let calendar = Calendar.current
        let workStartComponents = calendar.dateComponents([.hour, .minute], from: config.workStartTime)
        let workEndComponents = calendar.dateComponents([.hour, .minute], from: config.workEndTime)
        
        guard let startHour = workStartComponents.hour,
              let startMinute = workStartComponents.minute,
              let endHour = workEndComponents.hour,
              let endMinute = workEndComponents.minute,
              (endHour > startHour) || (endHour == startHour && endMinute > startMinute) else {
            throw AppError.validationError("工作结束时间必须晚于开始时间")
        }
        
        // 验证午休时间
        if let lunchStart = config.lunchStartTime,
           let lunchEnd = config.lunchEndTime {
            let lunchStartComponents = calendar.dateComponents([.hour, .minute], from: lunchStart)
            let lunchEndComponents = calendar.dateComponents([.hour, .minute], from: lunchEnd)
            
            guard let lunchStartHour = lunchStartComponents.hour,
                  let lunchStartMinute = lunchStartComponents.minute,
                  let lunchEndHour = lunchEndComponents.hour,
                  let lunchEndMinute = lunchEndComponents.minute,
                  (lunchEndHour > lunchStartHour) || (lunchEndHour == lunchStartHour && lunchEndMinute > lunchStartMinute) else {
                throw AppError.validationError("午休结束时间必须晚于开始时间")
            }
        }
    }
} 