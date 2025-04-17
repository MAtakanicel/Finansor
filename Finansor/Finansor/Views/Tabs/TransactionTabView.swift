import SwiftUI

struct TransactionTabView: View {
    @State private var showAddIncomeCategory = false
    @State private var categories: [ExpenseCategory] = [
        ExpenseCategory(
            name: "Maaş",
            icon: "dollarsign.circle.fill",
            color: AppColors.income,
            isIncome: true,
            isSystem: true,
            monthlyBudget: nil,
            monthlySpent: nil,
            monthlyIncome: 25000
        ),
        ExpenseCategory(
            name: "Freelance",
            icon: "latch.2.case.fill",
            color: Color.green,
            isIncome: true,
            isSystem: false,
            monthlyBudget: nil,
            monthlySpent: nil,
            monthlyIncome: 20000
        ),
        ExpenseCategory(
            name: "Yatırım Geliri",
            icon: "chart.line.uptrend.xyaxis",
            color: Color.blue,
            isIncome: true,
            isSystem: false,
            monthlyBudget: nil,
            monthlySpent: nil,
            monthlyIncome: 5200
        ),
        
        // Gider Kategorileri (Örndek)
        ExpenseCategory(
            name: "Faturalar",
            icon: "doc.text.fill",
            color: Color.red,
            isIncome: false,
            isSystem: true,
            monthlyBudget: 1500,
            monthlySpent: 1350,
            monthlyIncome: nil
        ),
        ExpenseCategory(
            name: "Abonelikler",
            icon: "arrow.clockwise",
            color: Color.green,
            isIncome: false,
            isSystem: false,
            monthlyBudget: 7500,
            monthlySpent: 3890,
            monthlyIncome: nil
        ),
        ExpenseCategory(
            name: "Market",
            icon: "cart.fill",
            color: Color.orange,
            isIncome: false,
            isSystem: false,
            monthlyBudget: 7500,
            monthlySpent: 3890,
            monthlyIncome: nil
        ),
        ExpenseCategory(
            name: "Ulaşım",
            icon: "car.fill",
            color: Color.blue,
            isIncome: false,
            isSystem: false,
            monthlyBudget: 1000,
            monthlySpent: 780,
            monthlyIncome: nil
        ),
        ExpenseCategory(
            name: "Eğlence",
            icon: "film.fill",
            color: Color.purple,
            isIncome: false,
            isSystem: false,
            monthlyBudget: 1000,
            monthlySpent: 950,
            monthlyIncome: nil
        ),
    
        ExpenseCategory(
            name: "Eğitim",
            icon: "book.fill",
            color: Color.green,
            isIncome: false,
            isSystem: false,
            monthlyBudget: 500,
            monthlySpent: 430,
            monthlyIncome: nil
        ),
        ExpenseCategory(
            name: "Spor",
            icon: "figure.run",
            color: Color.pink,
            isIncome: false,
            isSystem: false,
            monthlyBudget: 2000,
            monthlySpent: 1800,
            monthlyIncome: nil
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Hızlı İşlemler
                        VStack(spacing: 15) {
                            HStack {
                                Text("Hızlı İşlemler")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                Spacer()
                            }
                            
                            HStack(spacing: 15) {
                                NavigationLink(destination: AnalysisTabView()) {
                                    QuickActionButton(
                                        title: "Analizlerim",
                                        iconName: "chart.pie.fill",
                                        color: AppColors.accentYellow
                                    )
                                }
                                
                                Button(action: {
                                    showAddIncomeCategory = true
                                }) {
                                    QuickActionButton(
                                        title: "Gelir Ekle",
                                        iconName: "plus.circle.fill",
                                        color: AppColors.income
                                    )
                                }
                                
                                NavigationLink(destination: Text("Gider Ekle")) {
                                    QuickActionButton(
                                        title: "Gider Ekle",
                                        iconName: "minus.circle.fill",
                                        color: AppColors.expense
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Harcama Kategorileri
                        VStack(spacing: 15) {
                            NavigationLink(destination: ExpenseCategoriesView(initialCategoryType: .expense, sharedCategories: $categories)) {
                                NavigationOptionRow(
                                    title: "Harcama Kategorilerim",
                                    subtitle: "Gider kategorilerini yönet",
                                    iconName: "tag.fill",
                                    color: AppColors.expense
                                )
                            }
                            
                            NavigationLink(destination: ExpenseCategoriesView(initialCategoryType: .income, sharedCategories: $categories)) {
                                NavigationOptionRow(
                                    title: "Gelir Kategorilerim",
                                    subtitle: "Gelir kategorilerini yönet",
                                    iconName: "dollarsign.circle.fill",
                                    color: AppColors.income
                                )
                            }
                            
                            NavigationLink(destination: BudgetsView()) {
                                NavigationOptionRow(
                                    title: "Bütçelerim",
                                    subtitle: "Harcama bütçesi oluştur ve takip et",
                                    iconName: "chart.pie.fill",
                                    color: AppColors.expense
                                )
                            }
                            
                            NavigationLink(destination: RemindersView()) {
                                NavigationOptionRow(
                                    title: "Hatırlatıcılarım",
                                    subtitle: "Fatura ve ödeme hatırlatıcıları",
                                    iconName: "bell.fill",
                                    color: .purple
                                )
                            }
                            
                            NavigationLink(destination: BillsAndPaymentsView()) {
                                NavigationOptionRow(
                                    title: "Faturalarım",
                                    subtitle: "Fatura ve ödemelerini yönet",
                                    iconName: "doc.text.fill",
                                    color: .orange
                                )
                            }
                            
                            NavigationLink(destination: SubscriptionsView()) {
                                NavigationOptionRow(
                                    title: "Aboneliklerim",
                                    subtitle: "Düzenli ödemelerinizi yönet",
                                    iconName: "arrow.clockwise",
                                    color: .green
                                )
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("İşlemler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        //Bildirim Sayfası
                    }) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showAddIncomeCategory) {
                AddCategoryView(
                    isPresented: $showAddIncomeCategory,
                    categories: $categories,
                    isIncome: true
                )
            }
        }
    }
}

struct NavigationOptionRow: View {
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.2))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryTextDark)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.secondaryTextDark)
        }
        .padding(.vertical, 8)
    }
}

struct QuickActionButton: View {
    let title: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.textDark)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    TransactionTabView()
}
