# 进度报告

## 当前状态（2026-06-06）

V1「实时工资计数器」已完成并验证通过，可在模拟器运行。

## 本轮做了什么

从一个编译不过、装着虚假文档、压着大量游离代码的半成品，整理成一个能跑的极简产品：

### 清场
- 删除重复定义的 `Views/ContentView.swift`（编译撞车元凶）
- 把非 V1 代码移到 `archive/`：统计页、Widget、数据加密、联网节假日、Helper 等
- 修复工程缺失的 `SUPPORTED_PLATFORMS` 配置（命令行编译被劫持的根因）

### 重建
- 重写架构：去掉 `AppState`/`SalaryService`/`Repository` 服务层，改用 SwiftData 原生 `@Query`，根除"服务永远 nil"的 runtime bug
- 重写计算引擎 `SalaryCalculator`：纯函数、可测试，新增五时段判断（休息/上班前/工作中/午休/已下班）
- 新建实时工资主界面 `EarningsView`：`TimelineView(.periodic)` 每秒跳动
- 精简 `SalaryConfig`（去掉加班/节假日字段）、`ConfigView`（去掉坏掉的主题/导入导出）
- 重写引导页文案（去掉虚假的"节假日同步""桌面小组件"）

### 验证
- 12 个单元测试全部通过（覆盖计算引擎核心保证）
- UI 测试走查引导页→主界面通过
- 模拟器实跑截图确认：工作时段跳动、休息日显示"今天休息"

## 编译路径现状（7 个文件）

```
SalaryApp.swift
Models/SalaryConfig.swift
Models/HolidayConfig.swift
Utils/SalaryCalculator.swift
Views/EarningsView.swift
Views/ConfigView.swift
Views/Components/OnboardingView.swift
```

## 已知限制

- 节假日按"星期几"判断，未接入法定节假日/调休数据
- 无加班、税费计算
- 无 Widget、统计图表

## 下一步（V2 候选）

按优先级：接入节假日数据 → 桌面 Widget → 加班/税费 → 统计图表。
`archive/` 中有可参考的历史实现。
