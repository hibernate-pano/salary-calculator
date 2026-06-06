import SwiftUI
import SwiftData

/// 实时工资主界面。
///
/// 今日收入用 `TimelineView(.periodic)` 每秒刷新，数字实时跳动。
/// 本月 / 年度收入随之同步更新。
struct EarningsView: View {
    @Query private var configs: [SalaryConfig]
    @Query private var holidays: [HolidayConfig]

    private var config: SalaryConfig? { configs.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let config {
                    let calculator = SalaryCalculator(config: config, holidays: holidays)

                    // 每秒刷新一次，驱动今日收入实时跳动
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        VStack(spacing: 16) {
                            todayHero(calculator: calculator, now: context.date)

                            HStack(spacing: 16) {
                                summaryCard(
                                    title: "本月",
                                    amount: calculator.monthEarnings(asOf: context.date),
                                    icon: "calendar"
                                )
                                summaryCard(
                                    title: "年度",
                                    amount: calculator.yearEarnings(asOf: context.date),
                                    icon: "chart.line.uptrend.xyaxis"
                                )
                            }

                            perSecondHint(calculator: calculator, now: context.date)
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView(
                        "正在准备",
                        systemImage: "hourglass",
                        description: Text("正在初始化你的工资配置")
                    )
                    .padding(.top, 80)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("今天赚了多少")
        }
    }

    // MARK: - 今日收入主卡片（大数字，实时跳动）

    @ViewBuilder
    private func todayHero(calculator: SalaryCalculator, now: Date) -> some View {
        let amount = calculator.todayEarnings(asOf: now)

        VStack(spacing: 12) {
            Text("今日收入")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(amount, format: .currency(code: "CNY").precision(.fractionLength(2)))
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(value: amount))
                .animation(.snappy(duration: 0.3), value: amount)
                .foregroundStyle(amount > 0 ? Color.green : Color.secondary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            statusBadge(phase: calculator.phase(asOf: now))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private func statusBadge(phase: SalaryCalculator.DayPhase) -> some View {
        let (text, color): (String, Color) = {
            switch phase {
            case .dayOff:     return ("今天休息 · 好好放松", .blue)
            case .beforeWork: return ("还没到上班时间", .orange)
            case .working:    return ("正在赚钱中 💰", .green)
            case .lunchBreak: return ("午休中 · 暂停计薪", .orange)
            case .afterWork:  return ("今天到手 · 可以下班啦 🎉", .blue)
            }
        }()

        Text(text)
            .font(.footnote.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    // MARK: - 本月 / 年度小卡片

    private func summaryCard(title: String, amount: Double, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(amount, format: .currency(code: "CNY").precision(.fractionLength(2)))
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .contentTransition(.numericText(value: amount))
                .animation(.snappy(duration: 0.3), value: amount)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 每秒工资提示

    @ViewBuilder
    private func perSecondHint(calculator: SalaryCalculator, now: Date) -> some View {
        let perSecond = calculator.salaryPerSecond
        if perSecond > 0 {
            HStack {
                Image(systemName: "timer")
                Text("每秒 ") + Text(perSecond, format: .currency(code: "CNY").precision(.fractionLength(4))) + Text(" · 每分 ") + Text(perSecond * 60, format: .currency(code: "CNY").precision(.fractionLength(2)))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.top, 4)
        }
    }
}

#Preview {
    EarningsView()
        .modelContainer(for: [SalaryConfig.self, HolidayConfig.self], inMemory: true)
}
