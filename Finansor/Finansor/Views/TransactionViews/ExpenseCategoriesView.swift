import SwiftUI

struct ExpenseCategory: Identifiable {
    var id = UUID()
    var name: String
    var icon: String
    var color: Color
    var isIncome: Bool
    var isSystem: Bool
    var monthlyBudget: Double?
    var monthlySpent: Double?
    var monthlyIncome: Double?
}

struct ExpenseCategoriesView: View {
    @Binding var categories: [ExpenseCategory]
    @State private var showingAddCategory = false
    @State private var showingEditCategory = false
    @State private var categoryToEdit: ExpenseCategory?
    @State private var selectedCategoryType: CategoryType
    @Environment(\.editMode) private var editMode
    @State private var navigateToAnalysis = false
    @State private var showCategoryPicker: Bool = true
    @State private var showDeleteAlert = false
    @State private var categoryToDelete: ExpenseCategory?
    
    // Düzenleme için Kullanılan geçici değişkenler
    @State private var editName: String = ""
    @State private var editIcon: String = ""
    @State private var editColor: Color = .blue
    @State private var editBudget: String = ""
    @State private var editIncome: String = ""
    
    init(initialCategoryType: CategoryType = .expense, sharedCategories: Binding<[ExpenseCategory]>) {
        _selectedCategoryType = State(initialValue: initialCategoryType)
        // TransactionTabView üzerinden belirli bir kategori türüne doğrudan geçiş yapıldığında
        // kategori seçici gösterilmesin
        _showCategoryPicker = State(initialValue: false)
        _categories = sharedCategories
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Toplam Kategoriler - only show if we're allowing category type switching
                    if showCategoryPicker {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Gelir Kategorileri")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryTextDark)
                                
                                Text("\(incomeCategories.count)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.income)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 5) {
                                Text("Gider Kategorileri")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryTextDark)
                                
                                Text("\(expenseCategories.count)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.expense)
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                    }
                    
                    // Kategori Seçim ve Liste Başlığı
                    HStack {
                        Text(selectedCategoryType == .income ? "Gelir Kategorileri" : "Gider Kategorileri")
                            .font(.headline)
                            .foregroundColor(AppColors.textDark)
                        
                        Spacer()
                        
                        NavigationLink(destination: AnalysisTabView(), isActive: $navigateToAnalysis) {
                            EmptyView()
                        }
                        
                        Button(action: {
                            navigateToAnalysis = true
                        }) {
                            Image(systemName: "chart.pie.fill")
                                .foregroundColor(AppColors.secondaryTextDark)
                        }
                        
                        if showCategoryPicker {
                            Picker("", selection: $selectedCategoryType) {
                                Text("Gider").tag(CategoryType.expense)
                                Text("Gelir").tag(CategoryType.income)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 160)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Kategori Listesi
                    VStack(spacing: 0) {
                        let filteredCats = filteredCategories
                        ForEach(filteredCats) { category in
                            CategoryRowWithActions(
                                category: category,
                                onEdit: {
                                    prepareEditCategory(category: category)
                                },
                                onDelete: {
                                    categoryToDelete = category
                                    showDeleteAlert = true
                                }
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(AppColors.cardDark)
                            
                            if !filteredCats.isEmpty && category.id != filteredCats.last?.id {
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                                    .padding(.leading, 65)
                            }
                        }
                    }
                    .background(AppColors.cardDark)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle(selectedCategoryType == .income ? "Gelir Kategorilerim" : "Harcama Kategorilerim")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddCategory = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(
                isPresented: $showingAddCategory,
                categories: $categories,
                isIncome: selectedCategoryType == .income
            )
        }
        .sheet(isPresented: $showingEditCategory) {
            // Düzenleme için özel bir view kullanıyoruz
            EditCategorySheetView(
                isPresented: $showingEditCategory,
                categories: $categories,
                name: $editName,
                icon: $editIcon,
                color: $editColor,
                budget: $editBudget,
                income: $editIncome,
                categoryId: categoryToEdit?.id
            )
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Kategoriyi Sil"),
                message: Text("Bu kategoriyi silmek istediğinize emin misiniz? Bu işlem geri alınamaz."),
                primaryButton: .destructive(Text("Sil")) {
                    if let category = categoryToDelete, let index = categories.firstIndex(where: { $0.id == category.id }) {
                        categories.remove(at: index)
                    }
                },
                secondaryButton: .cancel(Text("İptal"))
            )
        }
    }
    
    var incomeCategories: [ExpenseCategory] {
        categories.filter { $0.isIncome }
    }
    
    var expenseCategories: [ExpenseCategory] {
        categories.filter { !$0.isIncome }
    }
    
    var filteredCategories: [ExpenseCategory] {
        selectedCategoryType == .income ? incomeCategories : expenseCategories
    }
    
    // Kategori düzenleme işlemini hazırlayan fonksiyon
    func prepareEditCategory(category: ExpenseCategory) {
        // Düzenleme değişkenlerini hazırla
        editName = category.name
        editIcon = category.icon
        editColor = category.color
        
        // Bütçe değerini ayarla (gider kategorisi için)
        if !category.isIncome, let budget = category.monthlyBudget {
            editBudget = "\(Int(budget))"
        } else {
            editBudget = ""
        }
        
        // Gelir değerini ayarla (gelir kategorisi için)
        if category.isIncome, let income = category.monthlyIncome {
            editIncome = "\(Int(income))"
        } else {
            editIncome = ""
        }
        
        // Kategori referansını kaydet
        categoryToEdit = category
        
        // Düzenleme ekranını göster
        showingEditCategory = true
    }
}

struct CategoryRowWithActions: View {
    let category: ExpenseCategory
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showOptions: Bool = false
    
    var body: some View {
        ZStack {
            // Ana satır içeriği
            Button(action: {
                if !category.isSystem {
                    showOptions = true
                }
            }) {
                HStack(spacing: 15) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(category.color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 18))
                            .foregroundColor(category.color)
                    }
                    
                    // Kategori tipi ve isimi
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.headline)
                            .foregroundColor(AppColors.textDark)
                        
                        HStack {
                            Text(category.isIncome ? "Gelir" : "Gider")
                                .font(.caption)
                                .foregroundColor(category.isIncome ? AppColors.income : AppColors.expense)
                            
                            if category.isSystem {
                                Text("(Sistem)")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryTextDark)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Gelir miktarı (Gelir kategorileri için)
                    if category.isIncome, let income = category.monthlyIncome {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("₺\(income, specifier: "%.0f")")
                                .font(.subheadline)
                                .foregroundColor(AppColors.income)
                            
                            Text("Aylık Gelir")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextDark)
                        }
                    }
                    
                    // Bütçe (Sadece Harcama kategorilerinde geçerli)
                    if !category.isIncome, let budget = category.monthlyBudget, let spent = category.monthlySpent {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("₺\(spent, specifier: "%.0f") / ₺\(budget, specifier: "%.0f")")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textDark)
                            
                            // Mini ilerleme durumu
                            ProgressView(value: min(spent, budget), total: budget)
                                .progressViewStyle(LinearProgressViewStyle(tint: progressColor(spent: spent, total: budget)))
                                .frame(width: 80, height: 4)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
        }
        .actionSheet(isPresented: $showOptions) {
            ActionSheet(
                title: Text(category.name),
                message: Text("Ne yapmak istiyorsunuz?"),
                buttons: [
                    .default(Text("Düzenle")) {
                        onEdit()
                    },
                    .destructive(Text("Sil")) {
                        onDelete()
                    },
                    .cancel(Text("İptal"))
                ]
            )
        }
    }
    
    func progressColor(spent: Double, total: Double) -> Color {
        let percentage = spent / total
        
        if percentage >= 1.0 {
            return AppColors.expense
        } else if percentage >= 0.8 {
            return AppColors.accentYellow
        } else {
            return AppColors.income
        }
    }
}

// Kategori Düzenleme için Özel Sheet View
struct EditCategorySheetView: View {
    @Binding var isPresented: Bool
    @Binding var categories: [ExpenseCategory]
    
    @Binding var name: String
    @Binding var icon: String
    @Binding var color: Color
    @Binding var budget: String
    @Binding var income: String
    
    var categoryId: UUID?
    @State private var category: ExpenseCategory?
    @State private var isLoaded: Bool = false
    
    // SF Semboller topluluğu
    let iconOptions = [
        "tag.fill", "cart.fill", "creditcard.fill", "banknote.fill", 
        "car.fill", "bus.fill", "tram.fill", "airplane", 
        "house.fill", "building.2.fill", "building.columns.fill",
        "fork.knife", "cup.and.saucer.fill", "wineglass.fill",
        "pill.fill", "cross.fill", "heart.fill", 
        "book.fill", "newspaper.fill", "graduationcap.fill",
        "sportscourt.fill", "figure.walk", "figure.run", 
        "gift.fill", "bag.fill", "case.fill",
        "theatermasks.fill", "ticket.fill", "gamecontroller.fill",
        "tv.fill", "music.note", "headphones", 
        "phone.fill", "laptopcomputer", "printer.fill",
        "dollarsign.circle.fill", "chart.line.uptrend.xyaxis", "chart.pie.fill"
    ]
    
    let colorOptions: [Color] = [
        .blue, .green, .red, .orange, .yellow, .purple, .pink, 
        AppColors.income, AppColors.expense, AppColors.accentYellow, AppColors.primaryBlue
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Icon ve Renk Preview bölgesi
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(color.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(color)
                            }
                            .padding(.bottom)
                            
                            // Kategori Tipi
                            if let category = category {
                                Text(category.isIncome ? "Gelir Kategorisi" : "Gider Kategorisi")
                                    .font(.headline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(category.isIncome ? AppColors.income.opacity(0.2) : AppColors.expense.opacity(0.2))
                                    .foregroundColor(category.isIncome ? AppColors.income : AppColors.expense)
                                    .cornerRadius(20)
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // TextField bölgesi
                        VStack(spacing: 15) {
                            // Kategorinin isimi
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kategori Adı")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                TextField("Ör. Alışveriş", text: $name)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(AppColors.textDark)
                            }
                            
                            // Gelir kategorileri için aylık gelir girişi
                            if let category = category, category.isIncome {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Aylık Gelir Miktarı")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    TextField("Ör. 5000", text: $income)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .foregroundColor(AppColors.textDark)
                                }
                            }
                            
                            // Aylık BÜtçesi (Sadece harcama Kategorileri)
                            if let category = category, !category.isIncome {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Aylık Bütçe (Opsiyonel)")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    TextField("Ör. 1000", text: $budget)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .foregroundColor(AppColors.textDark)
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Icon Picker
                        VStack(spacing: 15) {
                            Text("İkon Seç")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                                ForEach(iconOptions, id: \.self) { iconOption in
                                    ZStack {
                                        Circle()
                                            .fill(icon == iconOption ? color.opacity(0.2) : Color.gray.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: iconOption)
                                            .font(.system(size: 24))
                                            .foregroundColor(icon == iconOption ? color : AppColors.secondaryTextDark)
                                    }
                                    .onTapGesture {
                                        icon = iconOption
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Renk Picker
                        VStack(spacing: 15) {
                            Text("Renk Seç")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                                ForEach(colorOptions, id: \.self) { colorOption in
                                    Circle()
                                        .fill(colorOption)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: color == colorOption ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            color = colorOption
                                        }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                    }
                    .padding()
                }
                .onAppear {
                    loadCategoryData()
                }
            }
            .navigationTitle("Kategoriyi Düzenle")
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
                        saveCategory()
                    }
                    .foregroundColor(.white)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func loadCategoryData() {
        guard let id = categoryId, !isLoaded else { return }
        
        if let foundCategory = findCategory() {
            self.category = foundCategory
            
            // Var olan değerlerin üzerine tekrar yazalım
            name = foundCategory.name
            icon = foundCategory.icon
            color = foundCategory.color
            
            // Bütçe değerini yükle
            if !foundCategory.isIncome, let budget = foundCategory.monthlyBudget {
                self.budget = "\(Int(budget))"
            }
            
            // Gelir değerini yükle
            if foundCategory.isIncome, let income = foundCategory.monthlyIncome {
                self.income = "\(Int(income))"
            }
            
            isLoaded = true
            print("Kategori yüklendi: \(name), Bütçe: \(budget), Gelir: \(income)")
        }
    }
    
    // Kategoriyi bul
    private func findCategory() -> ExpenseCategory? {
        guard let id = categoryId else { return nil }
        return categories.first { $0.id == id }
    }
    
    // Kategoriyi güncelle
    private func saveCategory() {
        guard let id = categoryId, let index = categories.firstIndex(where: { $0.id == id }) else {
            isPresented = false
            return
        }
        
        var updatedCategory = categories[index]
        
        // Temel alanları güncelle
        updatedCategory.name = name
        updatedCategory.icon = icon
        updatedCategory.color = color
        
        // Kategori türüne göre diğer alanları güncelle
        if updatedCategory.isIncome {
            updatedCategory.monthlyIncome = Double(income) ?? updatedCategory.monthlyIncome
        } else {
            updatedCategory.monthlyBudget = Double(budget) ?? updatedCategory.monthlyBudget
        }
        
        // Güncellenmiş kategoriyi diziye geri koy
        categories[index] = updatedCategory
        
        print("Kategori güncellendi: \(updatedCategory.name), Bütçe: \(updatedCategory.monthlyBudget.map { "\($0)" } ?? "nil"), Gelir: \(updatedCategory.monthlyIncome.map { "\($0)" } ?? "nil")")
        
        isPresented = false
    }
}

struct AddCategoryView: View {
    @Binding var isPresented: Bool
    @Binding var categories: [ExpenseCategory]
    let isIncome: Bool
    
    @State private var name = ""
    @State private var selectedIcon = "tag.fill"
    @State private var selectedColor = Color.blue
    @State private var monthlyBudget = ""
    @State private var monthlyIncome = ""
    
    // SF Semboller topluluğu
    let iconOptions = [
        "tag.fill", "cart.fill", "creditcard.fill", "banknote.fill", 
        "car.fill", "bus.fill", "tram.fill", "airplane", 
        "house.fill", "building.2.fill", "building.columns.fill",
        "fork.knife", "cup.and.saucer.fill", "wineglass.fill",
        "pill.fill", "cross.fill", "heart.fill", 
        "book.fill", "newspaper.fill", "graduationcap.fill",
        "sportscourt.fill", "figure.walk", "figure.run", 
        "gift.fill", "bag.fill", "case.fill",
        "theatermasks.fill", "ticket.fill", "gamecontroller.fill",
        "tv.fill", "music.note", "headphones", 
        "phone.fill", "laptopcomputer", "printer.fill",
        "dollarsign.circle.fill", "chart.line.uptrend.xyaxis", "chart.pie.fill"
    ]
    
    let colorOptions: [Color] = [
        .blue, .green, .red, .orange, .yellow, .purple, .pink, 
        AppColors.income, AppColors.expense, AppColors.accentYellow, AppColors.primaryBlue
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Icon ve Renk Preview bölgesi
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(selectedColor.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(selectedColor)
                            }
                            .padding(.bottom)
                            
                            // Kategori Tipi
                            Text(isIncome ? "Gelir Kategorisi" : "Gider Kategorisi")
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isIncome ? AppColors.income.opacity(0.2) : AppColors.expense.opacity(0.2))
                                .foregroundColor(isIncome ? AppColors.income : AppColors.expense)
                                .cornerRadius(20)
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // TextField bölgesi
                        VStack(spacing: 15) {
                            // Kategorinin isimi
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kategori Adı")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                TextField("Ör. Alışveriş", text: $name)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(AppColors.textDark)
                            }
                            
                            // Gelir kategorileri için aylık gelir girişi
                            if isIncome {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Aylık Gelir Miktarı")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    TextField("Ör. 5000", text: $monthlyIncome)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .foregroundColor(AppColors.textDark)
                                }
                            }
                            
                            // Aylık BÜtçesi (Sadece harcama Kategorileri)
                            if !isIncome {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Aylık Bütçe (Opsiyonel)")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textDark)
                                    
                                    TextField("Ör. 1000", text: $monthlyBudget)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .foregroundColor(AppColors.textDark)
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Icon Picker
                        VStack(spacing: 15) {
                            Text("İkon Seç")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedIcon == icon ? selectedColor : AppColors.secondaryTextDark)
                                    }
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Renk Picker
                        VStack(spacing: 15) {
                            Text("Renk Seç")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                                ForEach(colorOptions, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
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
            .navigationTitle("Yeni Kategori")
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
                        let budgetValue = !isIncome ? Double(monthlyBudget) : nil
                        let incomeValue = isIncome ? Double(monthlyIncome) : nil
                        
                        let newCategory = ExpenseCategory(
                            name: name,
                            icon: selectedIcon,
                            color: selectedColor,
                            isIncome: isIncome,
                            isSystem: false,
                            monthlyBudget: budgetValue,
                            monthlySpent: 0,
                            monthlyIncome: incomeValue
                        )
                        
                        categories.append(newCategory)
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

enum CategoryType {
    case income, expense
}

#Preview {
    NavigationView {
        ExpenseCategoriesView(sharedCategories: .constant([
            // Gelir Kategorileri (Örndek)
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
        ]))
    }
} 
