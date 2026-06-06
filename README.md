# 工资计时器 (Salary Ticker)

一个 iOS「摸鱼神器」——上班时间里，看着自己赚的每一秒钱在屏幕上实时跳动。

用 SwiftUI + SwiftData 构建，简单、纯本地、无网络。

## 它做什么

打开 app，填上你的月薪和上下班时间，回到主页，就能看到：

- **今日收入**：工作时段内每秒实时增长的大数字
- **本月收入**：本月已完成工作日 + 今日实时累计
- **年度收入**：今年已完成月份 + 本月实时累计
- **每秒 / 每分进账**：直观感受时间的价值

它会按你所处的时段给出准确状态：

| 时段 | 状态文案 |
| --- | --- |
| 工作中 | 正在赚钱中 💰 |
| 上班前 | 还没到上班时间 |
| 午休中 | 午休中 · 暂停计薪 |
| 已下班 | 今天到手 · 可以下班啦 🎉 |
| 休息日 | 今天休息 · 好好放松 |

## 计算模型（V1）

- 每秒工资 = 月薪 ÷ 当月工作日数 ÷ 每日工作秒数
- 每日工作秒数 = 下班时间 − 上班时间 − 午休时长
- 工作日按"星期几"判断（默认周一到周五），午休时段不计薪
- 非工作日今日收入为 0

> 节假日 / 调休、加班倍率、税费等高级规则暂未启用，留待后续版本。

## 技术栈

- **SwiftUI** — 全部界面
- **SwiftData** — 配置本地持久化（`@Model` + `@Query`）
- **TimelineView(.periodic)** — 驱动每秒实时刷新
- 最低系统：iOS 18.2+ / Xcode 26+

## 项目结构

```
salary-calculator/
├── SalaryApp.swift            # App 入口 + 根视图 + 主 TabView
├── Models/
│   ├── SalaryConfig.swift     # 工资配置（SwiftData 模型）
│   └── HolidayConfig.swift    # 节假日配置（为后续预留）
├── Utils/
│   └── SalaryCalculator.swift # 实时工资计算引擎
└── Views/
    ├── EarningsView.swift     # 实时工资主界面
    ├── ConfigView.swift       # 设置页
    └── Components/
        └── OnboardingView.swift  # 首次启动引导

archive/                       # 后续版本可能用到的代码（统计图表、Widget 等），当前未编译
```

## 运行

用 Xcode 打开 `salary-calculator.xcodeproj`，选 iPhone 模拟器，Cmd+R。

命令行构建 / 测试：

```bash
# 构建
xcodebuild build -scheme salary-calculator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# 跑单元测试
xcodebuild test -scheme salary-calculator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:salary-calculatorTests
```

## 测试覆盖

`salary-calculatorTests` 覆盖计算引擎核心保证：

- 每日工作秒数（含 / 不含午休）
- 今日收入随时间递增（核心：会跳动）
- 上班前为 0、下班后为满额、午休期间不增长
- 休息日为 0、调休补班日计薪、法定节假日不计薪
- 非法配置（无工作日）返回 0，不产生 NaN
- 五个时段判断正确

## 后续计划（V2+）

- 接入法定节假日 / 调休数据
- 加班倍率、税前税后
- 桌面小组件
- 收入统计图表

`archive/` 目录里保留了上一轮探索的相关代码，可在实现这些功能时参考。
