# 薪资计算器 (Salary Calculator)

一个现代化的 iOS 薪资计算工具，采用 SwiftUI 开发，帮助用户精确计算和管理薪资信息。

[English Version](#english-version)

## ✨ 核心功能

- 💰 **多维度薪资计算**
  - 月薪、年薪转换
  - 税前税后计算
  - 社保公积金自动计算
  - 奖金个税计算
- 📊 **数据分析与可视化**
  - 收入构成分析
  - 税费明细展示
  - 历史数据追踪
  - 同比环比分析
- 🛠 **高级功能**
  - iOS 桌面小组件
  - iCloud 数据同步
  - 自定义计算参数
  - 多套方案对比
- 🎨 **现代化设计**
  - 原生 SwiftUI 界面
  - 深色/浅色模式
  - 自适应布局
  - 手势操作支持

## 🔧 技术规格

- **最低系统要求**
  - iOS 14.0+
  - Xcode 14.0+
  - Swift 5.5+
- **框架与依赖**
  - SwiftUI
  - Combine
  - WidgetKit
  - Core Data
  - Charts

## 📲 安装指南

1. 克隆仓库：

```bash
git clone https://github.com/yourusername/salary-calculator.git
cd salary-calculator
```

2. 安装依赖（如果使用 CocoaPods）：

```bash
pod install
```

3. 使用 Xcode 打开项目：

```bash
open SalaryCalculator.xcworkspace  # 如果使用 CocoaPods
# 或
open SalaryCalculator.xcodeproj    # 如果不使用 CocoaPods
```

## 📁 项目结构

```
SalaryCalculator/
├── App/                    # 应用程序入口
│   └── SalaryCalculatorApp.swift
├── Features/              # 功能模块
│   ├── Calculator/        # 计算器核心功能
│   ├── History/          # 历史记录
│   └── Settings/         # 设置
├── Core/                 # 核心组件
│   ├── Models/           # 数据模型
│   ├── Services/         # 业务服务
│   └── Utils/           # 工具类
├── UI/                   # 界面组件
│   ├── Components/       # 可复用组件
│   ├── Styles/          # 样式定义
│   └── Views/           # 页面视图
├── Data/                # 数据层
│   ├── CoreData/        # 数据持久化
│   └── Repository/      # 数据仓库
└── Widget/              # iOS 小组件
```

## 📱 小组件功能

### 支持的小组件类型

- **快捷计算小组件**
  - 尺寸：小号、中号
  - 功能：快速查看税前税后工资、社保公积金
  - 支持点击跳转到对应的详细页面
- **月度统计小组件**
  - 尺寸：中号、大号
  - 功能：展示月度收入分析图表
  - 支持自定义显示的数据类型
- **年度对比小组件**
  - 尺寸：大号
  - 功能：展示年度薪资趋势
  - 支持切换不同的统计维度

### 小组件配置

1. **添加小组件**

   - 长按主屏幕空白处
   - 点击左上角"+"号
   - 在小组件列表中找到"薪资计算器"
   - 选择需要的小组件类型和尺寸
   - 点击"添加小组件"

2. **自定义设置**
   - 长按小组件
   - 选择"编辑小组件"
   - 可配置项：
     - 显示数据类型
     - 更新频率
     - 展示样式
     - 点击操作

### 数据更新机制

- **实时数据更新**

  - 支持准实时数据更新（最快可达秒级）
  - 使用 App Intent 实现动态数据刷新
  - 通过 ActivityKit 实现实时数据展示
  - 利用 Live Activities 特性展示动态变化的数据

- **自动更新**

  - 系统自动刷新（基于系统策略和电池优化）
  - 当应用内数据发生变化时触发更新
  - 支持后台数据同步

- **手动更新**
  - 下拉小组件可强制刷新数据
  - 在应用内修改配置后自动同步

### 实时数据实现方案

```swift
// 1. 配置 Live Activity 支持
struct SalaryAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var currentSalary: Double
        var updateTime: Date
    }
}

// 2. 启动实时更新
func startLiveActivity() {
    let attributes = SalaryAttributes()
    let state = SalaryAttributes.ContentState(
        currentSalary: 10000,
        updateTime: Date()
    )

    do {
        let activity = try Activity.request(
            attributes: attributes,
            contentState: state,
            pushType: nil
        )
    } catch {
        print(error.localizedDescription)
    }
}

// 3. 更新数据
func updateLiveActivity(_ activity: Activity<SalaryAttributes>) {
    Task {
        let updatedState = SalaryAttributes.ContentState(
            currentSalary: calculateNewSalary(),
            updateTime: Date()
        )
        await activity.update(using: updatedState)
    }
}
```

### 性能优化

- 使用 WidgetKit 时间线保证更新效率
- 采用数据缓存机制减少内存占用
- 优化渲染性能，确保小组件流畅运行
- 实时数据更新时采用增量更新策略
- 根据数据变化频率自动调整更新间隔
- 实现智能节电模式，在低电量时降低更新频率

### 注意事项

1. **系统限制**

   - iOS 对小组件更新频率有限制
   - 频繁更新会增加电池消耗
   - 建议根据实际需求选择合适的更新策略

2. **最佳实践**

   - 对于秒级更新需求，建议使用 Live Activities 功能
   - 重要数据变化时才触发更新，避免无意义的刷新
   - 实现数据变化检测机制，只在必要时更新
   - 考虑使用预测算法，减少实际更新次数

3. **性能考虑**
   - 监控电池使用情况
   - 实现智能降频机制
   - 大数据量变化时使用增量更新
   - 添加用户配置选项，允许自定义更新频率

### 开发集成

```swift
// 在你的项目中添加小组件扩展
import WidgetKit
import SwiftUI

struct SalaryWidget: Widget {
    private let kind: String = "SalaryWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: SalaryTimelineProvider()
        ) { entry in
            SalaryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("工资概览")
        .description("显示税前税后工资信息")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

### 故障排除

常见问题：

1. 小组件不更新
   - 检查后台刷新权限
   - 确认网络连接状态
   - 重新添加小组件
2. 数据不同步
   - 确保 App Group 配置正确
   - 检查数据共享机制
   - 清除小组件缓存

## 🧪 测试覆盖

- **单元测试**：核心计算逻辑和业务规则
- **UI 测试**：关键用户流程
- **性能测试**：大数据量计算性能
- **快照测试**：UI 组件渲染

运行测试：

```bash
xcodebuild test -scheme SalaryCalculator -destination 'platform=iOS Simulator,name=iPhone 14'
```

## 🔐 安全特性

- 本地数据加密存储
- 安全的 iCloud 同步
- 隐私数据保护
- 无网络数据传输

## 👥 参与贡献

1. Fork 项目
2. 创建特性分支：`git checkout -b feature/NewFeature`
3. 提交更改：`git commit -am 'Add NewFeature'`
4. 推送分支：`git push origin feature/NewFeature`
5. 提交 Pull Request

## 📝 开发规范

- 遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- 使用 SwiftLint 进行代码规范检查
- 所有公开 API 必须有文档注释
- 遵循 MVVM 架构模式
- 编写单元测试，确保核心功能测试覆盖率 > 80%

## 📈 版本历史

- v1.1.0 (计划中)
  - 新增多币种支持
  - 优化计算性能
  - 增加数据导出功能
- v1.0.0
  - 首个正式版本发布
  - 完整的薪资计算功能
  - iOS 小组件支持

## 📄 开源协议

本项目采用 MIT 协议开源 - 查看 [LICENSE](LICENSE) 文件了解详情

---

# English Version

[Detailed English documentation will be added here...]

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/salary-calculator&type=Date)](https://star-history.com/#yourusername/salary-calculator&Date)

---

如果这个项目对你有帮助，欢迎 ⭐️ Star 支持！
