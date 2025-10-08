import SwiftUI

enum FinansorAnalysisPeriod: String, CaseIterable, Identifiable, Codable {
    case weekly = "Haftalık"
    case monthly = "Aylık"
    case yearly = "Yıllık"
    
    var id: String { self.rawValue }
}

enum FinansorAnalysisPage: String, CaseIterable, Identifiable, Codable {
    case expense = "Giderler"
    case income = "Gelirler"
    
    var id: String { self.rawValue }
    
    var title: String {
        self.rawValue
    }
    
    var icon: String {
        switch self {
        case .expense: return "arrow.down"
        case .income: return "arrow.up"
        }
    }
}

// Added new ChartSegment model for PieChartView
struct ChartSegment: Identifiable {
    var id = UUID()
    var name: String
    var value: Double
    var color: Color
}

struct AnalysisChartSegment: Identifiable, Codable {
    var id = UUID()
    var name: String
    var value: Double
    var color: Color
    
    enum CodingKeys: String, CodingKey {
        case id, name, value
        case colorR, colorG, colorB, colorA
    }
    
    init(id: UUID = UUID(), name: String, value: Double, color: Color) {
        self.id = id
        self.name = name
        self.value = value
        self.color = color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        value = try container.decode(Double.self, forKey: .value)
        
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
        try container.encode(value, forKey: .value)
        
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
}

struct AnalysisSummary {
    var totalIncome: Double
    var totalExpense: Double
    var netAmount: Double
    var period: String
    var incomeCategories: [AnalysisChartSegment]
    var expenseCategories: [AnalysisChartSegment]
    var savingsPercentage: Double
    
    var formattedTotalIncome: String {
        formatCurrency(totalIncome)
    }
    
    var formattedTotalExpense: String {
        formatCurrency(totalExpense)
    }
    
    var formattedNetAmount: String {
        formatCurrency(netAmount)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return "₺\(formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))")"
    }
} 