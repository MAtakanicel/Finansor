import SwiftUI

struct EditBudgetView: View {
    @Binding var isPresented: Bool
    @Binding var budgets: [FinansorBudget]
    var budget: FinansorBudget
    
    @State private var name: String
    @State private var amount: String
    @State private var category: FinansorBudgetCategory
    @State private var period: FinansorBudgetPeriod
    @State private var startDate: Date
    @State private var spent: String
    
    init(isPresented: Binding<Bool>, budgets: Binding<[FinansorBudget]>, budget: FinansorBudget) {
        self._isPresented = isPresented
        self._budgets = budgets
        self.budget = budget
        
        self._name = State(initialValue: budget.name)
        self._amount = State(initialValue: String(format: "%.2f", budget.amount))
        self._category = State(initialValue: budget.category)
        self._period = State(initialValue: budget.period)
        self._startDate = State(initialValue: budget.startDate)
        self._spent = State(initialValue: String(format: "%.2f", budget.spent))
    }
    
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
                            
                            // Harcanan miktar
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Harcanan Tutar")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                TextField("Ör. 500", text: $spent)
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
                            
                            // Bitiş tarihi (düzenlenemez)
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
            .navigationTitle("Bütçe Düzenle")
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
                        saveChanges()
                    }
                    .foregroundColor(.white)
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
              let spentValue = Double(spent.replacingOccurrences(of: ",", with: ".")) else {
            return
        }
        
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = FinansorBudget(
                id: budget.id,
                name: name,
                amount: amountValue,
                spent: spentValue,
                category: category,
                period: period,
                startDate: startDate,
                endDate: endDate
            )
        }
        
        isPresented = false
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct EditBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        EditBudgetView(
            isPresented: .constant(true),
            budgets: .constant([]),
            budget: FinansorBudget(
                id: UUID(),
                name: "Aylık Yemek Bütçesi",
                amount: 1200,
                spent: 800,
                category: .food,
                period: .monthly,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!
            )
        )
    }
} 
