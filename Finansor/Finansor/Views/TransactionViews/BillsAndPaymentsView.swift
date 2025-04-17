import SwiftUI

struct Bill: Identifiable {
    var id = UUID()
    var name: String
    var amount: Double
    var dueDate: Date
    var isPaid: Bool
    var category: BillCategory
    var isRecurring: Bool
}

enum BillCategory: String, CaseIterable, Identifiable {
    case electricity = "Elektrik"
    case water = "Su"
    case gas = "Doğalgaz"
    case internet = "Internet"
    case phone = "Telefon"
    case rent = "Kira"
    case other = "Diğer"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .electricity: return "bolt.fill"
        case .water: return "drop.fill"
        case .gas: return "flame.fill"
        case .internet: return "wifi"
        case .phone: return "phone.fill"
        case .rent: return "house.fill"
        case .other: return "doc.text.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .electricity: return .yellow
        case .water: return .blue
        case .gas: return .orange
        case .internet: return .purple
        case .phone: return .green
        case .rent: return .red
        case .other: return .gray
        }
    }
}

struct BillsAndPaymentsView: View {
    @State private var bills: [Bill] = [
        Bill(
            name: "Elektrik Faturası",
            amount: 250.75,
            dueDate: Calendar.current.date(byAdding: .day, value: 8, to: Date())!,
            isPaid: false,
            category: .electricity,
            isRecurring: true
        ),
        Bill(
            name: "Kira",
            amount: 9500,
            dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
            isPaid: false,
            category: .rent,
            isRecurring: true
        ),
        Bill(
            name: "Su Faturası",
            amount: 120.50,
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            isPaid: false,
            category: .water,
            isRecurring: true
        ),
        Bill(
            name: "İnternet",
            amount: 500.00,
            dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            isPaid: true,
            category: .internet,
            isRecurring: true
        ),
        Bill(
            name: "Telefon",
            amount: 310.00,
            dueDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            isPaid: true,
            category: .phone,
            isRecurring: true
        )
    ]
    
    @State private var selectedFilter: BillFilter = .all
    @State private var showingAddBill = false
    @State private var billToEdit: Bill? = nil
    @State private var showingDeleteAlert = false
    @State private var billToDelete: Bill? = nil
    
    var body: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Toplam
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Toplam Ödenen")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextDark)
                            
                            Text("₺\(String(format: "%.2f", totalPaid))")
                                .font(.headline)
                                .foregroundColor(AppColors.income)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("Bekleyen Ödemeler")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextDark)
                            
                            Text("₺\(String(format: "%.2f", totalUnpaid))")
                                .font(.headline)
                                .foregroundColor(AppColors.expense)
                        }
                    }
                    
                    Divider().background(Color.gray.opacity(0.3))
                    
                    // Yaklaşan Ödeme
                    if let nextBill = upcomingBill {
                        HStack(spacing: 15) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(AppColors.accentYellow)
                            
                            Text("Yaklaşan Ödeme: \(nextBill.name) - ₺\(String(format: "%.2f", nextBill.amount))")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textDark)
                            
                            Spacer()
                            
                            Text("\(daysUntil(nextBill.dueDate)) gün")
                                .font(.caption)
                                .padding(5)
                                .background(AppColors.expense.opacity(0.2))
                                .foregroundColor(AppColors.expense)
                                .cornerRadius(5)
                        }
                    }
                }
                .padding()
                .background(AppColors.cardDark)
                
                //FiltreTab
                filterTabsView
                
                // Fatura Listesi
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredBills) { bill in
                            BillRow(bill: bill, 
                                onUpdate: { updatedBill in
                                    if let index = bills.firstIndex(where: { $0.id == updatedBill.id }) {
                                        bills[index] = updatedBill
                                    }
                                },
                                onEdit: {
                                    billToEdit = bill
                                },
                                onDelete: {
                                    billToDelete = bill
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Fatura ve Ödemelerim")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddBill = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingAddBill) {
            AddBillView(isPresented: $showingAddBill, bills: $bills)
        }
        .sheet(item: $billToEdit) { bill in
            EditBillView(bill: bill, bills: $bills, isPresented: Binding(
                get: { billToEdit != nil },
                set: { if !$0 { billToEdit = nil } }
            ))
        }
        .alert("Faturayı Sil", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) {}
            Button("Sil", role: .destructive) {
                if let billToDelete = billToDelete, let index = bills.firstIndex(where: { $0.id == billToDelete.id }) {
                    bills.remove(at: index)
                }
            }
        } message: {
            if let bill = billToDelete {
                Text("\(bill.name) faturasını silmek istediğinize emin misiniz?")
            } else {
                Text("Bu faturayı silmek istediğinize emin misiniz?")
            }
        }
    }
    
    var totalPaid: Double {
        bills.filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var totalUnpaid: Double {
        bills.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var upcomingBill: Bill? {
        bills.filter { !$0.isPaid }
             .sorted { daysUntil($0.dueDate) < daysUntil($1.dueDate) }
             .first
    }
    
    var filteredBills: [Bill] {
        switch selectedFilter {
        case .all:
            return bills.sorted(by: { daysUntil($0.dueDate) < daysUntil($1.dueDate) })
        case .unpaid:
            return bills.filter { !$0.isPaid }.sorted(by: { daysUntil($0.dueDate) < daysUntil($1.dueDate) })
        case .paid:
            return bills.filter { $0.isPaid }.sorted(by: { daysUntil($0.dueDate) < daysUntil($1.dueDate) })
        case .overdue:
            return bills.filter { !$0.isPaid && daysUntil($0.dueDate) < 0 }.sorted(by: { daysUntil($0.dueDate) < daysUntil($1.dueDate) })
        case .upcoming:
            return bills.filter { !$0.isPaid && daysUntil($0.dueDate) >= 0 && daysUntil($0.dueDate) <= 7 }.sorted(by: { daysUntil($0.dueDate) < daysUntil($1.dueDate) })
        }
    }
    
    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: date)
        return components.day ?? 0
    }
    
    var filterTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(BillFilter.allCases, id: \.self) { filter in
                    BillFilterTab(
                        filter: filter,
                        isActive: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(AppColors.cardDark)
    }
}

enum BillFilter: String, CaseIterable {
    case all = "Tümü"
    case unpaid = "Ödenmeyenler"
    case paid = "Ödenenler"
    case overdue = "Gecikmiş"
    case upcoming = "Yaklaşan"
}

struct BillFilterTab: View {
    let filter: BillFilter
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(filter.rawValue)
                .font(.subheadline)
                .fontWeight(isActive ? .semibold : .regular)
                .foregroundColor(isActive ? .white : AppColors.secondaryTextDark)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    ZStack {
                        if isActive {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.accentYellow)
                        }
                    }
                )
        }
    }
}

struct BillRow: View {
    let bill: Bill
    let onUpdate: (Bill) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPaid: Bool
    @State private var showingOptions = false
    
    init(bill: Bill, onUpdate: @escaping (Bill) -> Void, onEdit: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.bill = bill
        self._isPaid = State(initialValue: bill.isPaid)
        self.onUpdate = onUpdate
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                // Icon
                ZStack {
                    Circle()
                        .fill(bill.category.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: bill.category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(bill.category.color)
                }
                
                // Bilgi
                VStack(alignment: .leading, spacing: 4) {
                    Text(bill.name)
                        .font(.headline)
                        .foregroundColor(AppColors.textDark)
                    
                    HStack {
                        Text(bill.category.rawValue)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextDark)
                        
                        if bill.isRecurring {
                            Image(systemName: "arrow.2.squarepath")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextDark)
                        }
                    }
                }
                
                Spacer()
                
                //Miktar ve ödemenme durumu
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₺\(String(format: "%.2f", bill.amount))")
                        .font(.headline)
                        .foregroundColor(AppColors.textDark)
                    
                    HStack {
                        Text(formatDate(bill.dueDate))
                            .font(.caption)
                            .foregroundColor(
                                statusColor(for: bill)
                            )
                        
                        Toggle("", isOn: $isPaid)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: AppColors.income))
                            .onChange(of: isPaid) { newValue in
                                var updatedBill = bill
                                updatedBill.isPaid = newValue
                                onUpdate(updatedBill)
                            }
                    }
                }
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                showingOptions = true
            }
        }
        .background(AppColors.cardDark)
        .cornerRadius(12)
        .actionSheet(isPresented: $showingOptions) {
            ActionSheet(
                title: Text(bill.name),
                message: Text("Ne yapmak istersiniz?"),
                buttons: [
                    .default(Text("Düzenle"), action: onEdit),
                    .destructive(Text("Sil"), action: onDelete),
                    .cancel(Text("İptal"))
                ]
            )
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    func statusColor(for bill: Bill) -> Color {
        if bill.isPaid {
            return AppColors.income
        }
        
        let days = daysUntil(bill.dueDate)
        if days < 0 {
            return AppColors.expense
        } else if days <= 3 {
            return AppColors.accentYellow
        } else {
            return AppColors.secondaryTextDark
        }
    }
    
    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: date)
        return components.day ?? 0
    }
}

struct AddBillView: View {
    @Binding var isPresented: Bool
    @Binding var bills: [Bill]
    
    @State private var name = ""
    @State private var amount = ""
    @State private var dueDate = Date()
    @State private var isPaid = false
    @State private var selectedCategory: BillCategory = .other
    @State private var isRecurring = true
    
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
                                ForEach(BillCategory.allCases) { category in
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(category == selectedCategory ? category.color.opacity(0.2) : Color.gray.opacity(0.1))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: category.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(category == selectedCategory ? category.color : AppColors.secondaryTextDark)
                                        }
                                        
                                        Text(category.rawValue)
                                            .font(.caption)
                                            .foregroundColor(AppColors.textDark)
                                    }
                                    .onTapGesture {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Form
                        VStack(spacing: 15) {
                            FormField(title: "Fatura Adı", placeholder: "Örn. Elektrik Faturası", text: $name)
                            
                            FormField(title: "Tutar", placeholder: "Örn. 250.50", text: $amount)
                                .keyboardType(.decimalPad)
                            
                            // Takvim (modifiyeli)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Son Ödeme Tarihi")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                DatePicker("", selection: $dueDate, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .accentColor(selectedCategory.color)
                                    .background(AppColors.cardDark)
                                    .cornerRadius(12)
                            }
                            
                            // Seçim (Düzenli ve tekli)
                            VStack(spacing: 10) {
                                Toggle("Ödendi", isOn: $isPaid)
                                    .foregroundColor(AppColors.textDark)
                                    .toggleStyle(SwitchToggleStyle(tint: AppColors.income))
                                    .padding(.horizontal, 4)
                                
                                Divider().background(Color.gray.opacity(0.3))
                                
                                Toggle("Düzenli Fatura", isOn: $isRecurring)
                                    .foregroundColor(AppColors.textDark)
                                    .toggleStyle(SwitchToggleStyle(tint: AppColors.accentYellow))
                                    .padding(.horizontal, 4)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni Fatura")
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
                        
                        let newBill = Bill(
                            name: name,
                            amount: amountValue,
                            dueDate: dueDate,
                            isPaid: isPaid,
                            category: selectedCategory,
                            isRecurring: isRecurring
                        )
                        
                        bills.append(newBill)
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}

struct EditBillView: View {
    let bill: Bill
    @Binding var bills: [Bill]
    @Binding var isPresented: Bool
    
    @State private var name: String
    @State private var amount: String
    @State private var dueDate: Date
    @State private var isPaid: Bool
    @State private var selectedCategory: BillCategory
    @State private var isRecurring: Bool
    
    init(bill: Bill, bills: Binding<[Bill]>, isPresented: Binding<Bool>) {
        self.bill = bill
        self._bills = bills
        self._isPresented = isPresented
        
        _name = State(initialValue: bill.name)
        _amount = State(initialValue: String(format: "%.2f", bill.amount))
        _dueDate = State(initialValue: bill.dueDate)
        _isPaid = State(initialValue: bill.isPaid)
        _selectedCategory = State(initialValue: bill.category)
        _isRecurring = State(initialValue: bill.isRecurring)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Kategori Pick
                        VStack(spacing: 15) {
                            Text("Kategori Seç")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 15) {
                                ForEach(BillCategory.allCases) { category in
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(category == selectedCategory ? category.color.opacity(0.2) : Color.gray.opacity(0.1))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: category.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(category == selectedCategory ? category.color : AppColors.secondaryTextDark)
                                        }
                                        
                                        Text(category.rawValue)
                                            .font(.caption)
                                            .foregroundColor(AppColors.textDark)
                                    }
                                    .onTapGesture {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // form
                        VStack(spacing: 15) {
                            FormField(title: "Fatura Adı", placeholder: "Örn. Elektrik Faturası", text: $name)
                            
                            FormField(title: "Tutar", placeholder: "Örn. 250.50", text: $amount)
                                .keyboardType(.decimalPad)
                            
                            // Takvim
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Son Ödeme Tarihi")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                DatePicker("", selection: $dueDate, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .accentColor(selectedCategory.color)
                                    .background(AppColors.cardDark)
                                    .cornerRadius(12)
                            }
                            
                            // Tip seçimi
                            VStack(spacing: 10) {
                                Toggle("Ödendi", isOn: $isPaid)
                                    .foregroundColor(AppColors.textDark)
                                    .toggleStyle(SwitchToggleStyle(tint: AppColors.income))
                                    .padding(.horizontal, 4)
                                
                                Divider().background(Color.gray.opacity(0.3))
                                
                                Toggle("Düzenli Fatura", isOn: $isRecurring)
                                    .foregroundColor(AppColors.textDark)
                                    .toggleStyle(SwitchToggleStyle(tint: AppColors.accentYellow))
                                    .padding(.horizontal, 4)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Faturayı Düzenle")
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
                        
                        let updatedBill = Bill(
                            id: bill.id,
                            name: name,
                            amount: amountValue,
                            dueDate: dueDate,
                            isPaid: isPaid,
                            category: selectedCategory,
                            isRecurring: isRecurring
                        )
                        
                        if let index = bills.firstIndex(where: { $0.id == bill.id }) {
                            bills[index] = updatedBill
                        }
                        
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        BillsAndPaymentsView()
    }
} 
