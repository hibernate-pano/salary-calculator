import Foundation
import SwiftData

/// 节假日 / 调休配置。
///
/// V1 不联网，此模型默认无数据 —— 此时工作日判断退化为"按星期几"。
/// 模型与静态判断方法保留，为后续接入节假日数据预留接口。
@Model
final class HolidayConfig {
    /// 日期
    var date: Date

    /// 名称（如"春节""国庆节"）
    var name: String

    /// 是否为调休补班日（true=该休息日需上班）
    var isWorkday: Bool

    var createdAt: Date

    init(date: Date, name: String, isWorkday: Bool = false) {
        self.date = date
        self.name = name
        self.isWorkday = isWorkday
        self.createdAt = Date()
    }

    /// 该日期是否为（放假的）节假日。
    static func isHoliday(_ date: Date, holidays: [HolidayConfig]) -> Bool {
        let calendar = Calendar.current
        return holidays.contains { calendar.isDate($0.date, inSameDayAs: date) && !$0.isWorkday }
    }

    /// 该日期是否为调休补班日。
    static func isWorkday(_ date: Date, holidays: [HolidayConfig]) -> Bool {
        let calendar = Calendar.current
        return holidays.contains { calendar.isDate($0.date, inSameDayAs: date) && $0.isWorkday }
    }
}
