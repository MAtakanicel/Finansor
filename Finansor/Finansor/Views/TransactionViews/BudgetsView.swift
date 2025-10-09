import SwiftUI

struct BudgetsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var budgetViewModel: BudgetViewModel
    
    @State private var selectedPeriod: FinansorBudgetPeriod = .monthly
    @State private var showingAddBudget = false
    @State private var editBudget: Budget? = nil
    @State private var showingDeleteAlert = false
    @State private var budgetToDelete: Budget? = nil
    @State private var showChartView = true
    
    var totalBudget: Double {
        budgetViewModel.budgets.reduce(0) { $0 + $1.amount }
    }
    
    var totalSpent: Double {
        budgetViewModel.budgets.reduce(0) { $0 + $1.spent }
    }
    
    var pieChartSegments: [ChartSegment] {
        let categoryBudgets = Dictionary(grouping: budgetViewModel.budgets, by: { $0.category })
            .mapValues { budgets in
                budgets.reduce(0) { $0 + $1.amount }
            }
        
        return categoryBudgets.map { (category, amount) in
            ChartSegment(
                name: category.rawValue,
                value: amount,
                color: category.color
            )
        }.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Bütçe özeti
                    VStack(spacing: 15) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Toplam Bütçe")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.secondaryTextDark)
                                
                                Text(totalBudget.asTRY)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.textDark)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 5) {
                                Text("Harcanan")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.secondaryTextDark)
                                
                                Text(totalSpent.asTRY)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(progressColor(spent: totalSpent, total: totalBudget))
                            }
                        }
                        
                        // İlerleme Barı
                        VStack(spacing: 8) {
                            ProgressView(value: min(totalSpent, totalBudget), total: max(totalBudget, 0.01))
                                .progressViewStyle(LinearProgressViewStyle(tint: progressColor(spent: totalSpent, total: totalBudget)))
                                .frame(height: 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                            
                            HStack {
                                Text("Kalan Bütçe: \(max(0, totalBudget - totalSpent).asTRY)")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryTextDark)
                                
                                Spacer()
                                
                                Text("\(percentageUsed(spent: totalSpent, total: totalBudget))% Kullanıldı")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryTextDark)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardDark)
                    .cornerRadius(12)
                    
                    // Bütçe Dağılımı (Pasta Grafik)
                    if showChartView && !budgets.isEmpty {
                        VStack(spacing: 15) {
                            HStack {
                                Text("Bütçe Dağılımı")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        showChartView.toggle()
                                    }
                                }) {
                                    Image(systemName: showChartView ? "chart.pie.fill" : "chart.pie")
                                        .foregroundColor(AppColors.secondaryTextDark)
                                }
                            }
                            
                            PieChartView(segments: pieChartSegments, width: 200)
                                .padding(.vertical)
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                    } else {
                        // Bütçe Başlığı
                        HStack {
                            Text("Bütçelerim")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    showChartView.toggle()
                                }
                            }) {
                                Image(systemName: showChartView ? "chart.pie.fill" : "chart.pie")
                                    .foregroundColor(AppColors.secondaryTextDark)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Bütçe Listesi
                    ForEach(budgetViewModel.budgets) { budget in
                        BudgetRowDetail(budget: budget, editAction: {
                            editBudget = budget
                        }, deleteAction: {
                            budgetToDelete = budget
                            showingDeleteAlert = true
                        })
                    }
                    
                    // Yeni Bütçe Ekle
                    Button(action: {
                        showingAddBudget = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            
                            Text("Yeni Bütçe Ekle")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(AppColors.accentYellow)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Bütçelerim")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddBudget = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView(isPresented: $showingAddBudget, budgets: $budgetViewModel.budgets)
        }
        .sheet(item: $editBudget) { budget in
            EditBudgetView(isPresented: Binding(
                get: { editBudget != nil },
                set: { if !$0 { editBudget = nil } }
            ), budgets: $budgetViewModel.budgets, budget: budget)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Bütçeyi Sil"),
                message: Text("Bu bütçeyi silmek istediğinizden emin misiniz?"),
                primaryButton: .destructive(Text("Sil")) {
                    if let budget = budgetToDelete,
                       let index = budgetViewModel.budgets.firstIndex(where: { $0.id == budget.id }) {
                        budgetViewModel.budgets.remove(at: index)
                    }
                },
                secondaryButton: .cancel(Text("İptal"))
            )
        }
    }
    
    func progressColor(spent: Double, total: Double) -> Color {
        if total <= 0 {
            return AppColors.income // Sıfır bütçe durumunda  renk
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

struct BudgetCard: View {
    let budget: FinansorBudget
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                // Icon
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
                
                // Miktar
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₺\(budget.amount, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(AppColors.textDark)
                    
                    Text("\(budget.period.rawValue)")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryTextDark)
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
                    Text("\(budget.spent.asTRY) / \(budget.amount.asTRY)")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryTextDark)
                    
                    Spacer()
                    
                    Text("\(percentageUsed(spent: budget.spent, total: budget.amount))% Kullanıldı")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryTextDark)
                }
            }
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(12)
    }
    
    func progressColor(spent: Double, total: Double) -> Color {
        if total <= 0 {
            return AppColors.income // Sıfır BÜtçe için renk
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

struct AddBudgetView: View {
    @Binding var isPresented: Bool
    @Binding var budgets: [FinansorBudget]
    
    @State private var name = ""
    @State private var amount = ""
    @State private var category: FinansorBudgetCategory = .food
    @State private var period: FinansorBudgetPeriod = .monthly
    @State private var startDate = Date()
    
    var endDate: Date {
        var dateComponent = DateComponents()
        
        switch period {
        case .weekly:
            dateComponent.day = 7
        case .monthly:
            dateComponent.month = 1
        case .half:
            dateComponent.month = 6
        case .yearly:
            dateComponent.year = 1
        }
        
        return Calendar.current.date(byAdding: dateComponent, to: startDate) ?? startDate
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Kategori Picker
                        VStack(spacing: 15) {
                            Text("Kategori Seç")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 15) {
                                ForEach(FinansorBudgetCategory.allCases) { cat in
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(cat == category ? cat.color.opacity(0.2) : Color.gray.opacity(0.1))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(cat == category ? cat.color : AppColors.secondaryTextDark)
                                        }
                                        
                                        Text(cat.rawValue)
                                            .font(.caption)
                                            .foregroundColor(AppColors.textDark)
                                    }
                                    .onTapGesture {
                                        category = cat
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Form
                        VStack(spacing: 15) {
                            // Bütçe İsimi
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bütçe Adı")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                TextField("Ör. Aylık Yemek Bütçesi", text: $name)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(AppColors.textDark)
                            }
                            
                            // Miktarı
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bütçe Tutarı")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                TextField("Ör. 2000", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(AppColors.textDark)
                            }
                            
                            // Period
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bütçe Periyodu")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                Picker("", selection: $period) {
                                    ForEach(FinansorBudgetPeriod.allCases) { period in
                                        Text(period.rawValue).tag(period)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            // Başlama Tarihi
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Başlangıç Tarihi")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .accentColor(category.color)
                                    .background(AppColors.cardDark)
                                    .cornerRadius(12)
                            }
                            
                            // Bitiş tarihi (düzenlenemez) (oto seçim)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bitiş Tarihi")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                HStack {
                                    Text(formatDate(endDate))
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .foregroundColor(AppColors.textDark)
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
            .navigationTitle("Yeni Bütçe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        guard let amountValue = Double(amount) else { return }
                        let newBudget = FinansorBudget.create(
                            name: name,
                            amount: amountValue,
                            category: category,
                            period: period,
                            startDate: startDate
                        )
                        budgets.append(newBudget)
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        BudgetsView()
    }
} 
