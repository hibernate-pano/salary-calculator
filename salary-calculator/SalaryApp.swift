import SwiftUI
import SwiftData

@main
struct SalaryApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [SalaryConfig.self, HolidayConfig.self])
    }
}

/// 根视图：首次启动展示引导页，之后进入主界面。
struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    init() {
        // UI 测试支持：传入 -resetOnboarding 时强制回到引导页
        if CommandLine.arguments.contains("-resetOnboarding") {
            UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        }
    }

    var body: some View {
        if hasSeenOnboarding {
            ContentView()
        } else {
            OnboardingView(isPresented: Binding(
                get: { !hasSeenOnboarding },
                set: { hasSeenOnboarding = !$0 }
            ))
        }
    }
}

/// 主界面：实时工资 + 设置两个 Tab。
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var configs: [SalaryConfig]

    var body: some View {
        TabView {
            EarningsView()
                .tabItem {
                    Label("工资", systemImage: "dollarsign.circle.fill")
                }

            ConfigView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
        .task {
            // 确保始终存在一份配置（首次启动时创建默认配置）
            if configs.isEmpty {
                modelContext.insert(SalaryConfig())
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [SalaryConfig.self, HolidayConfig.self], inMemory: true)
}
