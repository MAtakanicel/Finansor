import SwiftUI
import Foundation

struct FinansorTransaction: Identifiable, Equatable, Hashable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var categoryId: UUID
    var category: FinansorExpenseCategory?
    var isIncome: Bool
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, amount, date, categoryId, isIncome, notes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        amount = try container.decode(Double.self, forKey: .amount)
        date = try container.decode(Date.self, forKey: .date)
        categoryId = try container.decode(UUID.self, forKey: .categoryId)
        isIncome = try container.decode(Bool.self, forKey: .isIncome)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        // category is transient and will be set after decoding
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(isIncome, forKey: .isIncome)
        try container.encodeIfPresent(notes, forKey: .notes)
        // category is transient and won't be encoded
    }
    
    init(id: UUID = UUID(), title: String, amount: Double, date: Date, categoryId: UUID, category: FinansorExpenseCategory?, isIncome: Bool, notes: String? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.categoryId = categoryId
        self.category = category
        self.isIncome = isIncome
        self.notes = notes
    }
    
    // Equatable
    static func == (lhs: FinansorTransaction, rhs: FinansorTransaction) -> Bool {
        lhs.id == rhs.id
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Formatted display values
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    // Static factory methods
    static func createIncome(title: String, amount: Double, date: Date, category: FinansorExpenseCategory, notes: String? = nil) -> FinansorTransaction {
        FinansorTransaction(
            title: title,
            amount: amount,
            date: date,
            categoryId: category.id,
            category: category,
            isIncome: true,
            notes: notes
        )
    }
    
    static func createExpense(title: String, amount: Double, date: Date, category: FinansorExpenseCategory, notes: String? = nil) -> FinansorTransaction {
        FinansorTransaction(
            title: title,
            amount: amount,
            date: date,
            categoryId: category.id,
            category: category,
            isIncome: false,
            notes: notes
        )
    }
} 