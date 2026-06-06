import SwiftUI
import SwiftData

/// 设置页：编辑月薪、上下班时间、午休、工作日。
///
/// 直接绑定 SwiftData 模型，改动即时保存，无需"保存"按钮。
struct ConfigView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var configs: [SalaryConfig]

    private var config: SalaryConfig? { configs.first }

    /// Calendar.weekday 顺序：1=周日 … 7=周六
    private let weekdayOrder = [2, 3, 4, 5, 6, 7, 1]
    private let weekdayNames = [
        1: "周日", 2: "周一", 3: "周二", 4: "周三",
        5: "周四", 6: "周五", 7: "周六"
    ]

    var body: some View {
        NavigationStack {
            Form {
                if let config {
                    salarySection(config)
                    workTimeSection(config)
                    lunchSection(config)
                    workDaysSection(config)
                    aboutSection()
                } else {
                    Text("正在初始化…")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("设置")
            .onChange(of: configs.map(\.persistentModelID)) { _, _ in save() }
        }
    }

    // MARK: - 工资

    private func salarySection(_ config: SalaryConfig) -> some View {
        Section("月薪") {
            HStack {
                Text("税前月薪")
                Spacer()
                TextField(
                    "月薪",
                    value: Binding(
                        get: { config.monthlySalary },
                        set: { config.monthlySalary = max(0, $0); save() }
                    ),
                    format: .number
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 140)
                Text("元")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - 工作时间

    private func workTimeSection(_ config: SalaryConfig) -> some View {
        Section("工作时间") {
            DatePicker(
                "上班",
                selection: Binding(
                    get: { config.workStartTime },
                    set: { config.workStartTime = $0; save() }
                ),
                displayedComponents: .hourAndMinute
            )
            DatePicker(
                "下班",
                selection: Binding(
                    get: { config.workEndTime },
                    set: { config.workEndTime = $0; save() }
                ),
                displayedComponents: .hourAndMinute
            )
        }
    }

    // MARK: - 午休

    private func lunchSection(_ config: SalaryConfig) -> some View {
        Section("午休") {
            Toggle("启用午休", isOn: Binding(
                get: { config.lunchStartTime != nil },
                set: { enabled in
                    if enabled {
                        config.lunchStartTime = SalaryConfig.time(hour: 12, minute: 0)
                        config.lunchEndTime = SalaryConfig.time(hour: 13, minute: 0)
                    } else {
                        config.lunchStartTime = nil
                        config.lunchEndTime = nil
                    }
                    save()
                }
            ))

            if config.lunchStartTime != nil {
                DatePicker(
                    "午休开始",
                    selection: Binding(
                        get: { config.lunchStartTime ?? SalaryConfig.time(hour: 12, minute: 0) },
                        set: { config.lunchStartTime = $0; save() }
                    ),
                    displayedComponents: .hourAndMinute
                )
                DatePicker(
                    "午休结束",
                    selection: Binding(
                        get: { config.lunchEndTime ?? SalaryConfig.time(hour: 13, minute: 0) },
                        set: { config.lunchEndTime = $0; save() }
                    ),
                    displayedComponents: .hourAndMinute
                )
            }
        }
    }

    // MARK: - 工作日

    private func workDaysSection(_ config: SalaryConfig) -> some View {
        Section("工作日") {
            ForEach(weekdayOrder, id: \.self) { weekday in
                Toggle(weekdayNames[weekday] ?? "", isOn: Binding(
                    get: { config.workDays.contains(weekday) },
                    set: { isOn in
                        if isOn {
                            config.workDays.insert(weekday)
                        } else {
                            config.workDays.remove(weekday)
                        }
                        save()
                    }
                ))
            }
        }
    }

    // MARK: - 关于

    private func aboutSection() -> some View {
        Section("关于") {
            HStack {
                Text("版本")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func save() {
        config?.updatedAt = Date()
        try? modelContext.save()
    }
}

#Preview {
    ConfigView()
        .modelContainer(for: [SalaryConfig.self, HolidayConfig.self], inMemory: true)
}
