import SwiftUI

struct FinansorExpenseCategory: Identifiable, Equatable, Hashable, Codable {
    var id = UUID()
    var name: String
    var icon: String
    var color: Color
    var isIncome: Bool
    var isSystem: Bool
    var monthlyBudget: Double?
    var monthlySpent: Double?
    var monthlyIncome: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, isIncome, isSystem, monthlyBudget, monthlySpent, monthlyIncome
        case colorR, colorG, colorB, colorA
    }
    
    init(id: UUID = UUID(), name: String, icon: String, color: Color, isIncome: Bool, isSystem: Bool, monthlyBudget: Double? = nil, monthlySpent: Double? = nil, monthlyIncome: Double? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.isIncome = isIncome
        self.isSystem = isSystem
        self.monthlyBudget = monthlyBudget
        self.monthlySpent = monthlySpent
        self.monthlyIncome = monthlyIncome
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        isIncome = try container.decode(Bool.self, forKey: .isIncome)
        isSystem = try container.decode(Bool.self, forKey: .isSystem)
        monthlyBudget = try container.decodeIfPresent(Double.self, forKey: .monthlyBudget)
        monthlySpent = try container.decodeIfPresent(Double.self, forKey: .monthlySpent)
        monthlyIncome = try container.decodeIfPresent(Double.self, forKey: .monthlyIncome)
        
        // Decode color components
        let colorR = try container.decode(Double.self, forKey: .colorR)
        let colorG = try container.decode(Double.self, forKey: .colorG)
        let colorB = try container.decode(Double.self, forKey: .colorB)
        let colorA = try container.decode(Double.self, forKey: .colorA)
        
        self.color = Color(.sRGB, red: colorR, green: colorG, blue: colorB, opacity: colorA)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(isIncome, forKey: .isIncome)
        try container.encode(isSystem, forKey: .isSystem)
        try container.encodeIfPresent(monthlyBudget, forKey: .monthlyBudget)
        try container.encodeIfPresent(monthlySpent, forKey: .monthlySpent)
        try container.encodeIfPresent(monthlyIncome, forKey: .monthlyIncome)
        
        // Convert Color to RGBA components
        let uiColor = UIColor(self.color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        try container.encode(Double(red), forKey: .colorR)
        try container.encode(Double(green), forKey: .colorG)
        try container.encode(Double(blue), forKey: .colorB)
        try container.encode(Double(alpha), forKey: .colorA)
    }
    
    // Equatable
    static func == (lhs: FinansorExpenseCategory, rhs: FinansorExpenseCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Static factory methods for common categories
    static func createIncomeCategory(name: String, icon: String, color: Color, monthlyIncome: Double?) -> FinansorExpenseCategory {
        FinansorExpenseCategory(
            name: name,
            icon: icon,
            color: color,
            isIncome: true,
            isSystem: false,
            monthlyBudget: nil,
            monthlySpent: nil,
            monthlyIncome: monthlyIncome
        )
    }
    
    static func createExpenseCategory(name: String, icon: String, color: Color, monthlyBudget: Double?, monthlySpent: Double? = nil) -> FinansorExpenseCategory {
        FinansorExpenseCategory(
            name: name,
            icon: icon,
            color: color,
            isIncome: false,
            isSystem: false,
            monthlyBudget: monthlyBudget,
            monthlySpent: monthlySpent,
            monthlyIncome: nil
        )
    }
}

enum FinansorCategoryType: String, CaseIterable, Identifiable {
    case income = "Gelir"
    case expense = "Gider"
    
    // Expense categories
    case food = "Yemek"
    case transportation = "Ulaşım"
    case entertainment = "Eğlence"
    case shopping = "Alışveriş"
    case housing = "Konut"
    case utilities = "Faturalar"
    case health = "Sağlık"
    case education = "Eğitim"
    case other = "Diğer"
    
    // Income categories
    case salary = "Maaş"
    case investment = "Yatırım"
    case gift = "Hediye"
    case otherIncome = "Diğer Gelir"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .income: return "arrow.up"
        case .expense: return "arrow.down"
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .entertainment: return "film.fill"
        case .shopping: return "cart.fill"
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .other: return "square.grid.2x2.fill"
        case .salary: return "dollarsign.circle.fill"
        case .investment: return "chart.line.uptrend.xyaxis.circle.fill"
        case .gift: return "gift.fill"
        case .otherIncome: return "plus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .income: return FinansorColors.accentBlue
        case .expense: return FinansorColors.expense
        case .food: return .orange
        case .transportation: return .blue
        case .entertainment: return .purple
        case .shopping: return .pink
        case .housing: return FinansorColors.expense
        case .utilities: return .yellow
        case .health: return .red
        case .education: return .green
        case .other: return .gray
        case .salary: return .green
        case .investment: return .blue
        case .gift: return .purple
        case .otherIncome: return .orange
        }
    }
} 