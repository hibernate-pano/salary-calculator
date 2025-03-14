import Foundation

enum AppError: LocalizedError {
    case dataError(String)
    case networkError(String)
    case syncError(String)
    case validationError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .dataError(let message):
            return "数据错误: \(message)"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .syncError(let message):
            return "同步错误: \(message)"
        case .validationError(let message):
            return "验证错误: \(message)"
        case .unknownError(let message):
            return "未知错误: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .dataError:
            return "请尝试重新启动应用或清除应用数据"
        case .networkError:
            return "请检查网络连接后重试"
        case .syncError:
            return "请稍后重试同步操作"
        case .validationError:
            return "请检查输入数据是否正确"
        case .unknownError:
            return "请重启应用或联系支持"
        }
    }
} 