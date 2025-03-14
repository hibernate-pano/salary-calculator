import SwiftUI
import SwiftData

@main
struct SalaryApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    // 初始化应用
                    await appState.initialize()
                }
        }
        .modelContainer(for: [SalaryConfig.self, HolidayConfig.self])
    }
}

class AppState: ObservableObject {
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var salaryConfig: SalaryConfig?
    @Published var holidayConfigs: [HolidayConfig] = []
    @Published var showOnboarding = false
    
    private(set) var salaryService: SalaryService?
    private let userDefaults = UserDefaults.standard
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    init() {
        showOnboarding = !userDefaults.bool(forKey: hasSeenOnboardingKey)
    }
    
    // 初始化服务
    func setupServices(context: ModelContext) {
        let salaryRepo = SalaryConfigRepository(context: context)
        let holidayRepo = HolidayConfigRepository(context: context)
        salaryService = SalaryService(repository: salaryRepo, holidayRepository: holidayRepo)
    }
    
    // 初始化应用
    @MainActor
    func initialize() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let service = salaryService else {
                throw AppError.unknownError("服务未初始化")
            }
            
            // 1. 加载工资配置
            salaryConfig = try service.getCurrentConfig()
            
            // 2. 同步节假日数据
            try await HolidayConfig.syncCurrentYearHolidays()
            
            // 3. 加载节假日配置
            holidayConfigs = try service.holidayRepository.fetch()
        } catch {
            self.error = error as? AppError ?? AppError.unknownError(error.localizedDescription)
        }
    }
    
    // 更新工资配置
    func updateSalaryConfig(_ config: SalaryConfig) {
        do {
            guard let service = salaryService else {
                throw AppError.unknownError("服务未初始化")
            }
            
            try service.updateConfig(config)
            salaryConfig = config
        } catch {
            self.error = error as? AppError ?? AppError.unknownError(error.localizedDescription)
        }
    }
    
    // 同步节假日数据
    @MainActor
    func syncHolidays() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await HolidayConfig.syncCurrentYearHolidays()
            guard let service = salaryService else {
                throw AppError.unknownError("服务未初始化")
            }
            holidayConfigs = try service.holidayRepository.fetch()
        } catch {
            self.error = error as? AppError ?? AppError.unknownError(error.localizedDescription)
        }
    }
    
    // 计算月工资
    func calculateMonthlySalary(year: Int, month: Int) -> Double? {
        do {
            guard let service = salaryService else {
                throw AppError.unknownError("服务未初始化")
            }
            return try service.calculateMonthlySalary(year: year, month: month)
        } catch {
            self.error = error as? AppError ?? AppError.unknownError(error.localizedDescription)
            return nil
        }
    }
    
    // 清除错误
    func clearError() {
        error = nil
    }
    
    // 完成引导
    func completeOnboarding() {
        userDefaults.set(true, forKey: hasSeenOnboardingKey)
        showOnboarding = false
    }
}

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Group {
            if appState.showOnboarding {
                OnboardingView(isPresented: $appState.showOnboarding)
                    .onDisappear {
                        appState.completeOnboarding()
                    }
            } else {
                TabView {
                    ConfigView()
                        .tabItem {
                            Label("设置", systemImage: "gear")
                        }
                    
                    StatisticsView()
                        .tabItem {
                            Label("统计", systemImage: "chart.bar")
                        }
                }
                .overlay {
                    if appState.isLoading {
                        LoadingOverlay(message: "加载中...")
                    }
                }
                .alert(error: $appState.error) { error in
                    Alert(
                        title: Text("错误"),
                        message: Text(error.localizedDescription),
                        dismissButton: .default(Text("确定")) {
                            appState.clearError()
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
} 