import SwiftUI
import Foundation

// Modeli benzersiz yapan prefix ekliyorum
struct FinansorBudget: Identifiable, Equatable, Hashable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var spent: Double
    var category: FinansorBudgetCategory
    var period: FinansorBudgetPeriod
    var startDate: Date
    var endDate: Date
    
    // Equatable
    static func == (lhs: FinansorBudget, rhs: FinansorBudget) -> Bool {
        lhs.id == rhs.id
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Computed properties
    var percentageSpent: Double {
        guard amount > 0 else { return 0 }
        return min(spent / amount, 1.0)
    }
    
    var remainingAmount: Double {
        return max(amount - spent, 0)
    }
    
    var isOverBudget: Bool {
        return spent > amount
    }
    
    // Static methods
    static func create(name: String, amount: Double, category: FinansorBudgetCategory, period: FinansorBudgetPeriod, startDate: Date) -> FinansorBudget {
        let endDate: Date
        
        switch period {
        case .weekly:
            endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        case .monthly:
            endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        case .half:
            endDate = Calendar.current.date(byAdding: .month, value: 6, to: startDate) ?? startDate
        case .yearly:
            endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        }
        
        return FinansorBudget(
            id: UUID(),
            name: name,
            amount: amount,
            spent: 0,
            category: category,
            period: period,
            startDate: startDate,
            endDate: endDate
        )
    }
    
    // Added initializer for clarity and consistency
    init(id: UUID = UUID(), name: String, amount: Double, spent: Double, category: FinansorBudgetCategory, period: FinansorBudgetPeriod, startDate: Date, endDate: Date) {
        self.id = id
        self.name = name
        self.amount = amount
        self.spent = spent
        self.category = category
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
    }
}

enum FinansorBudgetCategory: String, CaseIterable, Identifiable, Codable {
    case food = "Yemek"
    case transportation = "Ulaşım"
    case entertainment = "Eğlence"
    case shopping = "Alışveriş"
    case housing = "Konut"
    case utilities = "Faturalar"
    case health = "Sağlık"
    case education = "Eğitim"
    case other = "Diğer"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .entertainment: return "film.fill"
        case .shopping: return "cart.fill"
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transportation: return .blue
        case .entertainment: return .purple
        case .shopping: return .pink
        case .housing: return FinansorColors.expense
        case .utilities: return .yellow
        case .health: return .red
        case .education: return .green
        case .other: return .gray
        }
    }
}

enum FinansorBudgetPeriod: String, CaseIterable, Identifiable, Codable {
    case weekly = "Haftalık"
    case monthly = "Aylık"
    case half = "6 Aylık"
    case yearly = "Yıllık"
    
    var id: String { self.rawValue }
} 