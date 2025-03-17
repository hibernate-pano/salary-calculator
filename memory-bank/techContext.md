# 薪资计算器技术上下文

## 开发环境

### 系统要求

- macOS 13.0+
- Xcode 14.0+
- iOS 14.0+ (目标平台)

### 开发工具

- Xcode
- Git
- CocoaPods (可选)
- SwiftLint (代码规范)

## 技术栈

### 核心框架

1. **SwiftUI**

   - 用于构建用户界面
   - 支持声明式 UI
   - 提供响应式编程

2. **Combine**

   - 用于响应式编程
   - 处理异步事件
   - 数据流管理

3. **Core Data**

   - 本地数据持久化
   - 数据模型管理
   - 关系数据存储

4. **WidgetKit**
   - iOS 小组件开发
   - 小组件数据更新
   - 小组件交互

### 第三方依赖

1. **Charts**

   - 数据可视化
   - 图表展示
   - 交互式图表

2. **SwiftLint**
   - 代码规范检查
   - 代码风格统一
   - 代码质量保证

## 项目配置

### 1. 项目设置

```swift
// Info.plist 配置
<key>CFBundleDevelopmentRegion</key>
<string>$(DEVELOPMENT_LANGUAGE)</string>
<key>CFBundleExecutable</key>
<string>$(EXECUTABLE_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
<key>CFBundleInfoDictionaryVersion</key>
<string>6.0</string>
<key>CFBundleName</key>
<string>$(PRODUCT_NAME)</string>
<key>CFBundlePackageType</key>
<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
<key>CFBundleShortVersionString</key>
<string>1.0</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>LSRequiresIPhoneOS</key>
<true/>
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
</dict>
<key>UILaunchScreen</key>
<dict/>
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>armv7</string>
</array>
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
```

### 2. 构建设置

- Swift 版本: 5.5
- 部署目标: iOS 14.0
- 架构: arm64
- 优化级别: -O

### 3. 签名配置

- 开发团队
- 证书配置
- Provisioning Profile

## 开发规范

### 1. 代码风格

```swift
// 命名规范
struct UserProfile { }  // 类型使用大驼峰
let userName = ""      // 变量使用小驼峰
let MAX_COUNT = 10     // 常量使用大写下划线

// 函数规范
func calculateSalary(amount: Double) -> Double {
    // 实现
}

// 注释规范
/// 计算薪资
/// - Parameters:
///   - amount: 税前金额
/// - Returns: 税后金额
func calculateSalary(amount: Double) -> Double {
    // 实现
}
```

### 2. 文件组织

```
Project/
├── App/
│   └── SalaryApp.swift
├── Views/
│   ├── Components/
│   └── Screens/
├── Models/
│   └── Data/
├── Services/
│   └── Network/
├── Utils/
│   └── Extensions/
└── Resources/
    └── Assets/
```

### 3. Git 规范

- 分支命名: feature/, bugfix/, hotfix/
- 提交信息: feat:, fix:, docs:, style:, refactor:
- 版本标签: v1.0.0

## 构建流程

### 1. 开发构建

```bash
# 清理构建
xcodebuild clean

# 构建项目
xcodebuild build

# 运行测试
xcodebuild test
```

### 2. 发布构建

```bash
# 归档
xcodebuild archive

# 导出
xcodebuild -exportArchive
```

## 部署流程

### 1. 测试环境

- TestFlight 分发
- 内部测试
- 用户反馈

### 2. 生产环境

- App Store 发布
- 版本更新
- 用户通知

## 监控工具

### 1. 性能监控

- Instruments
- Xcode Metrics
- Firebase Performance

### 2. 崩溃监控

- Crashlytics
- Xcode Organizer
- 日志分析

## 安全措施

### 1. 数据安全

- Keychain 存储
- 数据加密
- 安全传输

### 2. 代码安全

- 代码混淆
- 反调试
- 完整性校验

## 测试环境

### 1. 单元测试

- XCTest
- 测试覆盖率
- 模拟对象

### 2. UI 测试

- XCUITest
- 界面自动化
- 用户交互测试

## 文档工具

### 1. 代码文档

- Swift-DocC
- 注释规范
- API 文档

### 2. 项目文档

- Markdown
- Mermaid
- PlantUML
