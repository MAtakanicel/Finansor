import Foundation

struct AppConstants {
    static let totalRegistrationSteps = 5
    
    struct API {
        static let baseURL = "https://api.finansor.com"
        static let timeout: TimeInterval = 30
    }
    
    struct UserDefaults {
        static let userSessionKey = "userSession"
        static let appThemeKey = "appTheme"
        static let notificationsEnabledKey = "notificationsEnabled"
    }
} 