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

// MARK: - Formatting Helpers
extension NumberFormatter {
    static let tryCurrency: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.numberStyle = .currency
        f.currencyCode = "TRY"
        f.maximumFractionDigits = 0
        f.minimumFractionDigits = 0
        return f
    }()
}

extension Double {
    var asTRY: String {
        NumberFormatter.tryCurrency.string(from: NSNumber(value: self)) ?? "₺\(Int(self))"
    }
}