import Foundation

struct User: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var email: String
    var photoURL: String?
    var createdAt: Date
    var lastLoginAt: Date
    var settings: UserSettings
    
    // Equatable
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

struct UserSettings: Codable, Equatable {
    var darkModeEnabled: Bool = true
    var notificationsEnabled: Bool = true
    var reminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    var currency: UserCurrency = .turkishLira
    var budgetReminderEnabled: Bool = true
    var weekStartDay: UserWeekday = .monday
    var language: UserLanguage = .turkish
    
    // Equatable
    static func == (lhs: UserSettings, rhs: UserSettings) -> Bool {
        lhs.darkModeEnabled == rhs.darkModeEnabled &&
        lhs.notificationsEnabled == rhs.notificationsEnabled &&
        lhs.reminderTime == rhs.reminderTime &&
        lhs.currency == rhs.currency &&
        lhs.budgetReminderEnabled == rhs.budgetReminderEnabled &&
        lhs.weekStartDay == rhs.weekStartDay &&
        lhs.language == rhs.language
    }
}

enum UserCurrency: String, Codable, CaseIterable, Identifiable {
    case turkishLira = "₺" // Turkish Lira
    case usd = "$" // US Dollar
    case eur = "€" // Euro
    case gbp = "£" // British Pound
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .turkishLira: return "Türk Lirası"
        case .usd: return "Amerikan Doları"
        case .eur: return "Euro"
        case .gbp: return "İngiliz Sterlini"
        }
    }
}

enum UserWeekday: Int, Codable, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case saturday = 7
    
    var id: Int { self.rawValue }
    
    var name: String {
        switch self {
        case .sunday: return "Pazar"
        case .monday: return "Pazartesi"
        case .saturday: return "Cumartesi"
        }
    }
}

enum UserLanguage: String, Codable, CaseIterable, Identifiable {
    case turkish = "tr"
    case english = "en"
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "İngilizce"
        }
    }
} 