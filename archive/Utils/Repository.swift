import Foundation
import SwiftData

// Repository 协议
protocol Repository {
    associatedtype T
    
    func fetch() throws -> [T]
    func add(_ item: T) throws
    func update(_ item: T) throws
    func delete(_ item: T) throws
    func deleteAll() throws
}

// 薪资配置仓库
class SalaryConfigRepository: Repository {
    typealias T = SalaryConfig
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetch() throws -> [SalaryConfig] {
        let descriptor = FetchDescriptor<SalaryConfig>()
        return try context.fetch(descriptor)
    }
    
    func add(_ item: SalaryConfig) throws {
        context.insert(item)
        try context.save()
    }
    
    func update(_ item: SalaryConfig) throws {
        try context.save()
    }
    
    func delete(_ item: SalaryConfig) throws {
        context.delete(item)
        try context.save()
    }
    
    func deleteAll() throws {
        let items = try fetch()
        items.forEach { context.delete($0) }
        try context.save()
    }
}

// 节假日配置仓库
class HolidayConfigRepository: Repository {
    typealias T = HolidayConfig
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetch() throws -> [HolidayConfig] {
        let descriptor = FetchDescriptor<HolidayConfig>()
        return try context.fetch(descriptor)
    }
    
    func add(_ item: HolidayConfig) throws {
        context.insert(item)
        try context.save()
    }
    
    func update(_ item: HolidayConfig) throws {
        try context.save()
    }
    
    func delete(_ item: HolidayConfig) throws {
        context.delete(item)
        try context.save()
    }
    
    func deleteAll() throws {
        let items = try fetch()
        items.forEach { context.delete($0) }
        try context.save()
    }
    
    // 获取指定年份的节假日
    func fetchHolidays(year: Int) throws -> [HolidayConfig] {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: year))!
        let endOfYear = calendar.date(from: DateComponents(year: year + 1))!
        
        var descriptor = FetchDescriptor<HolidayConfig>()
        descriptor.predicate = #Predicate<HolidayConfig> { holiday in
            holiday.date >= startOfYear && holiday.date < endOfYear
        }
        
        return try context.fetch(descriptor)
    }
} 