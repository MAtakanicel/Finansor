import SwiftUI


struct Transaction: Identifiable {
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var isIncome: Bool
}

struct HomeTabView: View {
    @State private var transactions: [Transaction] = [
        Transaction(title: "Maaş", amount: 20000, date: Date().addingTimeInterval(-86400), isIncome: true),
        Transaction(title: "Fatura Ödemesi", amount: 810, date: Date().addingTimeInterval(-259200), isIncome: false),
        Transaction(title: "Kira", amount: 9500, date: Date().addingTimeInterval(-345600), isIncome: false)
    ]
    
    @State private var totalIncome: Double = 50200
    @State private var totalExpense: Double = 11540
    @State private var savingsGoal: Double = 10000
    @State private var currentSavings: Double = 6600
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Bütçe özeti
                        VStack(spacing: 15) {
                            HStack {
                                Text("Bütçe Özeti")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                Spacer()
                            }
                            
                            HStack(spacing: 15) {
                                SummaryItem(title: "Gelir", amount: totalIncome, color: AppColors.income)
                                SummaryItem(title: "Gider", amount: totalExpense, color: AppColors.expense)
                                SummaryItem(title: "Kalan", amount: totalIncome - totalExpense, color: AppColors.accentYellow)
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // mini analiz ekranı
                        VStack(spacing: 15) {
                            HStack {
                                Text("Mini Analiz")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                Spacer()
                            }
                            
                            HStack(alignment: .top, spacing: 20) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Haftalık Değişim")
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.secondaryTextDark)
                                    
                                    HStack {
                                        Image(systemName: "arrow.up")
                                            .foregroundColor(AppColors.income)
                                        Text("+₺1,250")
                                            .foregroundColor(AppColors.income)
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                    .frame(height: 40)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Son Ay Değişim")
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.secondaryTextDark)
                                    
                                    HStack {
                                        Image(systemName: "arrow.down")
                                            .foregroundColor(AppColors.expense)
                                        Text("-₺850")
                                            .foregroundColor(AppColors.expense)
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Birikim Hedefi
                        VStack(spacing: 15) {
                            HStack {
                                Text("Birikim Hedefi")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                Spacer()
                                
                                Text("₺\(Int(currentSavings))/₺\(Int(savingsGoal))")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.secondaryTextDark)
                            }
                            
                            ProgressView(value: currentSavings, total: savingsGoal)
                                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accentYellow))
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                            
                            HStack {
                                Text("\(Int((currentSavings / savingsGoal) * 100))% Tamamlandı")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryTextDark)
                                Spacer()
                                Text("₺\(Int(savingsGoal - currentSavings)) kaldı")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryTextDark)
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Yaklaşan Ödemeler.
                        VStack(spacing: 15) {
                            HStack {
                                Text("Yaklaşan Ödemeler")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                Spacer()
                                
                                Button(action: {}) {
                                    Text("Tümünü Gör")
                                        .font(.caption)
                                        .foregroundColor(AppColors.accentYellow)
                                }
                            }
                            
                            ReminderItem(title: "Elektrik Faturası", date: "15 Nisan", amount: "₺250")
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            ReminderItem(title: "Kira Ödemesi", date: "20 Nisan", amount: "₺9,500")
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Son İşlemler
                        VStack(spacing: 15) {
                            HStack {
                                Text("Son İşlemler")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                Spacer()
                                
                                Button(action: {}) {
                                    Text("Tümünü Gör")
                                        .font(.caption)
                                        .foregroundColor(AppColors.accentYellow)
                                }
                            }
                            
                            ForEach(transactions.prefix(3)) { transaction in
                                TransactionRow(transaction: transaction)
                                
                                if transaction.id != transactions.prefix(3).last?.id {
                                    Divider().background(Color.gray.opacity(0.3))
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Ana Sayfa")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Bildirim aksiyonu
                    }) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}


struct SummaryItem: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryTextDark)
            
            Text("₺\(formattedAmount)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }
}

struct ReminderItem: View {
    let title: String
    let date: String
    let amount: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .foregroundColor(AppColors.textDark)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryTextDark)
            }
            
            Spacer()
            
            Text(amount)
                .foregroundColor(AppColors.expense)
                .fontWeight(.medium)
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Circle()
                .fill(transaction.isIncome ? AppColors.income : AppColors.expense)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: transaction.isIncome ? "arrow.down" : "arrow.up")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.title)
                    .foregroundColor(AppColors.textDark)
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryTextDark)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Text("\(transaction.isIncome ? "+" : "-")₺\(formattedAmount(transaction.amount))")
                .foregroundColor(transaction.isIncome ? AppColors.income : AppColors.expense)
                .fontWeight(.semibold)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func formattedAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }
}

#Preview {
    HomeTabView()
}
