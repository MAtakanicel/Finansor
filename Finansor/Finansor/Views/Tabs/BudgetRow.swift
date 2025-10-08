import SwiftUI

struct BudgetRow: View {
    let budget: FinansorBudget
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                // Kategori ikonu
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: categoryIcon)
                        .foregroundColor(categoryColor)
                }
                
                // Bütçe adı ve kategori
                VStack(alignment: .leading, spacing: 2) {
                    Text(budget.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(budget.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Bütçe tutarı
                VStack(alignment: .trailing, spacing: 2) {
                    Text("₺\(Int(budget.spent)) / ₺\(Int(budget.amount))")
                        .font(.subheadline)
                        .foregroundColor(budget.isOverBudget ? FinansorColors.expense : .white)
                    
                    Text("\(Int(budget.percentageSpent * 100))%")
                        .font(.caption)
                        .foregroundColor(progressColor)
                }
            }
            
            // İlerleme çubuğu
            ProgressView(value: budget.percentageSpent, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .background(Color.white.opacity(0.1))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .padding()
        .background(FinansorColors.cardDark)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Computed Properties
    
    private var progressColor: Color {
        if budget.percentageSpent >= 1.0 {
            return FinansorColors.expense
        } else if budget.percentageSpent >= 0.85 {
            return .orange
        } else {
            return FinansorColors.income
        }
    }
    
    private var categoryIcon: String {
        return budget.category.icon
    }
    
    private var categoryColor: Color {
        return budget.category.color
    }
}

struct BudgetRowView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            FinansorColors.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                BudgetRow(budget: FinansorBudget(
                    name: "Aylık Yemek Bütçesi",
                    amount: 5000,
                    spent: 3200,
                    category: .food,
                    period: .monthly,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(2592000) // 30 gün
                ))
                
                BudgetRow(budget: FinansorBudget(
                    name: "Eğlence Bütçesi",
                    amount: 1500,
                    spent: 1500,
                    category: .entertainment,
                    period: .monthly,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(2592000) // 30 gün
                ))
                
                BudgetRow(budget: FinansorBudget(
                    name: "Kıyafet Bütçesi",
                    amount: 2000,
                    spent: 2200,
                    category: .shopping,
                    period: .monthly,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(2592000) // 30 gün
                ))
            }
            .padding(.vertical)
        }
    }
} 