import SwiftUI
import Charts

// 工资数据结构
struct SalaryData: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let type: String
}

struct StatisticsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var salaryData: [SalaryData] = []
    @State private var isCalculating = false
    
    private let months = Array(1...12)
    private let years = Array(2020...2030)
    
    var body: some View {
        NavigationView {
            List {
                Section("时间选择") {
                    Picker("年份", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(year)年").tag(year)
                        }
                    }
                    
                    Picker("月份", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text("\(month)月").tag(month)
                        }
                    }
                }
                
                Section("工资统计") {
                    if let salary = appState.calculateMonthlySalary(year: selectedYear, month: selectedMonth) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("预计工资")
                                .font(.headline)
                            Text("¥ \(String(format: "%.2f", salary))")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 8)
                    } else {
                        Text("计算工资时出错")
                            .foregroundColor(.red)
                    }
                }
                
                // 每日工资图表
                Section("每日工资详情") {
                    if isCalculating {
                        ProgressView("计算中...")
                            .frame(height: 200)
                    } else if !salaryData.isEmpty {
                        Chart(salaryData) { data in
                            BarMark(
                                x: .value("日期", data.date, unit: .day),
                                y: .value("工资", data.amount)
                            )
                            .foregroundStyle(by: .value("类型", data.type))
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                if let date = value.as(Date.self) {
                                    AxisValueLabel {
                                        Text("\(Calendar.current.component(.day, from: date))")
                                    }
                                }
                            }
                        }
                    } else {
                        Text("无数据")
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // 工资类型占比
                Section("工资类型占比") {
                    if !salaryData.isEmpty {
                        let totalAmount = salaryData.reduce(0) { $0 + $1.amount }
                        let groupedData = Dictionary(grouping: salaryData, by: { $0.type })
                            .mapValues { items in
                                items.reduce(0) { $0 + $1.amount }
                            }
                        
                        Chart {
                            ForEach(Array(groupedData.keys), id: \.self) { type in
                                if let amount = groupedData[type] {
                                    SectorMark(
                                        angle: .value("工资", amount),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 1
                                    )
                                    .foregroundStyle(by: .value("类型", type))
                                    .annotation(position: .overlay) {
                                        Text("\(Int(amount / totalAmount * 100))%")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .frame(height: 200)
                    } else {
                        Text("无数据")
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // 月度趋势
                Section("月度趋势") {
                    if !salaryData.isEmpty {
                        let dailyTotals = salaryData.reduce(into: [:]) { result, data in
                            let day = Calendar.current.component(.day, from: data.date)
                            result[day, default: 0] += data.amount
                        }
                        
                        Chart {
                            ForEach(Array(dailyTotals.keys).sorted(), id: \.self) { day in
                                LineMark(
                                    x: .value("日期", day),
                                    y: .value("工资", dailyTotals[day] ?? 0)
                                )
                                .interpolationMethod(.catmullRom)
                                
                                AreaMark(
                                    x: .value("日期", day),
                                    y: .value("工资", dailyTotals[day] ?? 0)
                                )
                                .opacity(0.1)
                                .interpolationMethod(.catmullRom)
                            }
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: 5)) { value in
                                AxisValueLabel {
                                    Text("\(value.as(Int.self) ?? 0)")
                                }
                            }
                        }
                    } else {
                        Text("无数据")
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                if let config = appState.salaryConfig {
                    Section("基本信息") {
                        InfoRow(title: "基本月薪", value: String(format: "%.2f", config.monthlySalary))
                        InfoRow(title: "加班倍率", value: String(format: "%.1f", config.overtimeRate))
                        InfoRow(title: "节假日倍率", value: String(format: "%.1f", config.holidayOvertimeRate))
                    }
                    
                    Section("工作时间") {
                        let calendar = Calendar.current
                        let startComponents = calendar.dateComponents([.hour, .minute], from: config.workStartTime)
                        let endComponents = calendar.dateComponents([.hour, .minute], from: config.workEndTime)
                        
                        InfoRow(title: "上班时间", 
                               value: String(format: "%02d:%02d", 
                                          startComponents.hour ?? 0,
                                          startComponents.minute ?? 0))
                        
                        InfoRow(title: "下班时间",
                               value: String(format: "%02d:%02d",
                                          endComponents.hour ?? 0,
                                          endComponents.minute ?? 0))
                        
                        if let lunchStart = config.lunchStartTime,
                           let lunchEnd = config.lunchEndTime {
                            let lunchStartComponents = calendar.dateComponents([.hour, .minute], from: lunchStart)
                            let lunchEndComponents = calendar.dateComponents([.hour, .minute], from: lunchEnd)
                            
                            InfoRow(title: "午休开始",
                                   value: String(format: "%02d:%02d",
                                              lunchStartComponents.hour ?? 0,
                                              lunchStartComponents.minute ?? 0))
                            
                            InfoRow(title: "午休结束",
                                   value: String(format: "%02d:%02d",
                                              lunchEndComponents.hour ?? 0,
                                              lunchEndComponents.minute ?? 0))
                        }
                    }
                }
            }
            .navigationTitle("工资统计")
            .onChange(of: selectedYear) { _ in
                calculateSalaryData()
            }
            .onChange(of: selectedMonth) { _ in
                calculateSalaryData()
            }
            .onAppear {
                calculateSalaryData()
            }
        }
    }
    
    private func calculateSalaryData() {
        guard let service = appState.salaryService else { return }
        
        isCalculating = true
        salaryData.removeAll()
        
        Task {
            let calendar = Calendar.current
            guard let startDate = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)),
                  let range = calendar.range(of: .day, in: .month, for: startDate) else {
                isCalculating = false
                return
            }
            
            var newData: [SalaryData] = []
            
            for day in 1...range.count {
                if let date = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: day)) {
                    do {
                        let holidays = try await appState.holidayConfigs
                        
                        // 判断工作类型
                        let isHoliday = HolidayConfig.isHoliday(date, holidays: holidays)
                        let weekday = calendar.component(.weekday, from: date)
                        let isWorkday = appState.salaryConfig?.workDays.contains(weekday) ?? false
                        
                        // 计算工资
                        if let salary = try? service.calculateSalary(for: date) {
                            let type: String
                            if isHoliday {
                                type = "节假日"
                            } else if isWorkday {
                                if let config = appState.salaryConfig,
                                   let overtimeStart = config.overtimeStartTime,
                                   let overtimeEnd = config.overtimeEndTime {
                                    let overtimeSeconds = config.calculateOvertimeSeconds(for: date)
                                    if overtimeSeconds > 0 {
                                        type = "加班"
                                    } else {
                                        type = "正常工作日"
                                    }
                                } else {
                                    type = "正常工作日"
                                }
                            } else {
                                type = "休息日"
                            }
                            
                            newData.append(SalaryData(date: date, amount: salary, type: type))
                        }
                    } catch {
                        continue
                    }
                }
            }
            
            await MainActor.run {
                salaryData = newData
                isCalculating = false
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(AppState())
} 