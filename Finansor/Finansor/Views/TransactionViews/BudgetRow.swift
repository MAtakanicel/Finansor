import SwiftUI

struct BudgetRow: View {
    var budget: Budget
    var editAction: () -> Void
    var deleteAction: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Başlık ve İkonlar
            HStack {
                // Kategori ikonu
                ZStack {
                    Circle()
                        .fill(budget.category.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: budget.category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(budget.category.color)
                }
                
                // Başlık ve Kategori
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.name)
                        .font(.headline)
                        .foregroundColor(AppColors.textDark)
                    
                    Text(budget.category.rawValue)
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryTextDark)
                }
                
                Spacer()
                
                // Düzenle/Sil Butonları
                HStack(spacing: 15) {
                    Button(action: editAction) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryTextDark)
                    }
                    
                    Button(action: deleteAction) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.expense.opacity(0.7))
                    }
                }
            }
            
            // Bütçe Detayları ve Progress Bar
            VStack(spacing: 12) {
                // Rakamlar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dönem")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextDark)
                        Text(budget.period.rawValue)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textDark)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Miktar")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextDark)
                        Text("₺\(budget.amount, specifier: "%.0f")")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textDark)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Harcanan")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextDark)
                        Text("₺\(budget.spent, specifier: "%.0f")")
                            .font(.subheadline)
                            .foregroundColor(budget.spent > budget.amount ? AppColors.expense : AppColors.textDark)
                    }
                }
                
                // İlerleme Barı
                VStack(spacing: 8) {
                    ProgressView(value: min(budget.spent, budget.amount), total: max(budget.amount, 0.01))
                        .progressViewStyle(LinearProgressViewStyle(tint: progressColor(spent: budget.spent, total: budget.amount)))
                        .frame(height: 8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                    
                    HStack {
                        Text("₺\(max(0, budget.amount - budget.spent), specifier: "%.0f") kaldı")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextDark)
                        
                        Spacer()
                        
                        Text("\(percentageUsed(spent: budget.spent, total: budget.amount))% kullanıldı")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextDark)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(12)
    }
    
    func progressColor(spent: Double, total: Double) -> Color {
        if total <= 0 {
            return AppColors.income
        }
        
        let percentage = spent / total
        
        if percentage >= 1.0 {
            return AppColors.expense
        } else if percentage >= 0.8 {
            return AppColors.accentYellow
        } else {
            return AppColors.income
        }
    }
    
    func percentageUsed(spent: Double, total: Double) -> Int {
        if total <= 0 {
            return spent > 0 ? 100 : 0
        }
        return Int((spent / total) * 100)
    }
}

struct BudgetRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            BudgetRow(
                budget: Budget(
                    id: UUID(),
                    name: "Aylık Yemek Bütçesi",
                    amount: 1200,
                    spent: 800,
                    category: .food,
                    period: .monthly,
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!
                ),
                editAction: {},
                deleteAction: {}
            )
            .padding()
        }
    }
} 