import SwiftUI

struct AnalysisTabView: View {
    // Örnek kategori verileri
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
            monthlyBudget: 300,
            monthlySpent: 250,
            monthlyIncome: nil
        )
    ]
    
    @State private var selectedPeriod: AnalysisPeriod = .monthly
    @State private var selectedTab: Int = 0
    @State private var selectedPage: AnalysisPage = .expense
    @Namespace private var animation
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Sayfa seçimi
                    pageSelectionView()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Dönem seçimi
                            VStack {
                                Picker("", selection: $selectedPeriod) {
                                    ForEach(AnalysisPeriod.allCases) { period in
                                        Text(period.rawValue).tag(period)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.horizontal)
                                .padding(.top)
                                
                                // Haftalar, Aylar ve Yıllar segmentleri
                                if selectedPeriod == .weekly {
                                    periodTabView(options: ["Bu Hafta", "Geçen Hafta", "2 Hafta Önce"])
                                } else if selectedPeriod == .monthly {
                                    periodTabView(options: ["Bu Ay", "Geçen Ay", "3 Ay Önce"])
                                } else {
                                    periodTabView(options: ["2025", "2024", "2023"])
                                }
                            }
                            
                            if selectedPage == .expense {
                                expenseAnalysisView()
                            } else {
                                incomeAnalysisView()
                            }
                            
                            Spacer(minLength: 50)
                        }
                    }
                }
            }
            .navigationTitle(selectedPage == .expense ? "Harcama Analizi" : "Gelir Analizi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
    
    // Sayfa seçim görünümü
    private func pageSelectionView() -> some View {
        HStack(spacing: 0) {
            ForEach(AnalysisPage.allCases, id: \.self) { page in
                Button(action: {
                    withAnimation {
                        selectedPage = page
                    }
                }) {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: page.icon)
                            Text(page.title)
                        }
                        .font(.callout)
                        .foregroundColor(selectedPage == page ? .white : AppColors.secondaryTextDark)
                        
                        if selectedPage == page {
                            Rectangle()
                                .fill(AppColors.primaryBlue)
                                .frame(height: 3)
                                .matchedGeometryEffect(id: "page_indicator", in: animation)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 3)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .background(AppColors.cardDark)
    }
    
    // Harcama analizi sayfası
    @ViewBuilder
    private func expenseAnalysisView() -> some View {
        // Harcama dağılımı grafiği
        expenseCategoriesSummaryView(showTable: false)
            .padding(.horizontal)
        
        // Harcama kategorileri listesi
        VStack(spacing: 10) {
            HStack {
                Text("Harcama Kategorileri")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Button(action: {
                    // Kategorileri görüntüle butonu
                }) {
                    Label("Detaylar", systemImage: "list.bullet")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories.filter { !$0.isIncome }, id: \.id) { category in
                        CategoryBubble(category: category)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(12)
        .padding(.horizontal)
        
        // Aylık Harcama Analizi
        VStack(spacing: 15) {
            HStack {
                Text("Aylık Harcama Analizi")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textDark)
                Spacer()
            }
            .padding(.horizontal)
            
            // Örnek Bar Chart Verisi
            let barData = [
                BarChartData(label: "Oca", value: 32000, color: .blue),
                BarChartData(label: "Şub", value: 34400, color: .green),
                BarChartData(label: "Mar", value: 50300, color: .orange),
                BarChartData(label: "Nis", value: 21200, color: .purple),
                BarChartData(label: "May", value: 43000, color: .pink)
            ]
            
            BarChartView(data: barData, title: "Aylık Harcamalar", maxBarHeight: 150)
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // Gelir analizi sayfası
    @ViewBuilder
    private func incomeAnalysisView() -> some View {
        // Gelir dağılımı grafiği
        incomeCategoriesSummaryView(showTable: false)
            .padding(.horizontal)
        
        // Gelir kategorileri listesi
        VStack(spacing: 10) {
            HStack {
                Text("Gelir Kategorileri")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Button(action: {
                    // Gelir kategorilerini görüntüle butonu
                }) {
                    Label("Detaylar", systemImage: "list.bullet")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories.filter { $0.isIncome }, id: \.id) { category in
                        IncomeCategoryBubble(category: category)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(12)
        .padding(.horizontal)
        
        // Aylık Gelir Analizi
        VStack(spacing: 15) {
            HStack {
                Text("Aylık Gelir Analizi")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textDark)
                Spacer()
            }
            .padding(.horizontal)
            
            // Örnek Bar Chart Verisi
            let barData = [
                BarChartData(label: "Oca", value: 48500, color: .green),
                BarChartData(label: "Şub", value: 51000, color: .green),
                BarChartData(label: "Mar", value: 49050, color: .green),
                BarChartData(label: "Nis", value: 50200, color: .green),
                BarChartData(label: "May", value: 50200, color: .green)
            ]
            
            BarChartView(data: barData, title: "Aylık Gelirler", maxBarHeight: 150)
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // Gelir Kategorileri Özeti Görünümü
    @ViewBuilder
    private func incomeCategoriesSummaryView(showTable: Bool = true) -> some View {
        let incomeCategories = categories.filter { $0.isIncome && $0.monthlyIncome != nil && $0.monthlyIncome! > 0 }
        let sortedIncomeCategories = incomeCategories.sorted { ($0.monthlyIncome ?? 0) > ($1.monthlyIncome ?? 0) }
        let totalMonthlyIncome = incomeCategories.reduce(0) { $0 + ($1.monthlyIncome ?? 0) }
        
        let chartSegments = incomeCategories.map { category in
            ChartSegment(
                name: category.name,
                value: category.monthlyIncome ?? 0,
                color: category.color
            )
        }.sorted { $0.value > $1.value }
        
        VStack(spacing: 20) {
            // Başlık
            HStack {
                Text("Gelir Dağılımı")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Text("Bu Ay")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryTextDark)
            }
            .padding(.horizontal)
            
            // Donut Chart
            if chartSegments.isEmpty {
                Text("Henüz gelir verisi yok")
                    .foregroundColor(AppColors.secondaryTextDark)
                    .padding(.vertical, 40)
            } else {
                DonutChartView(
                    segments: chartSegments,
                    width: 220,
                    title: "₺\(Int(totalMonthlyIncome))",
                    subtitle: "Toplam"
                )
                .padding(.vertical, 10)
            }
            
            // Gelir Kategorileri Tablosu - Eğer showTable true ise ve veri varsa
            if showTable && !incomeCategories.isEmpty {
                incomeCategoriesTable(sortedIncomeCategories: sortedIncomeCategories)
            }
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(12)
    }
    
    private func incomeCategoriesTable(sortedIncomeCategories: [ExpenseCategory]) -> some View {
        VStack(spacing: 10) {
            // Kategori tablosu başlığı
            HStack {
                Text("Gelir Detayları")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 5)
            
            // Başlık satırı
            HStack {
                Text("Kategori")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryTextDark)
                
                Spacer()
                
                Text("Gelir")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryTextDark)
                    .frame(width: 80)
            }
            .padding(.horizontal)
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // Kategori satırları (maksimum 4 göster)
            ForEach(0..<min(sortedIncomeCategories.count, 4), id: \.self) { index in
                let category = sortedIncomeCategories[index]
                let isLast = index == min(sortedIncomeCategories.count, 4) - 1
                incomeCategoryRow(for: category, isLast: isLast)
            }
            
            // 4'ten fazla kategori varsa "Tümünü görüntüle" butonu göster
            if sortedIncomeCategories.count > 4 {
                Button(action: {
                    // Kategori detayları ekranına git butonu
                }) {
                    Text("Tüm gelir kategorilerini görüntüle (\(sortedIncomeCategories.count))")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryBlue)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(.vertical, 8)
        .background(AppColors.cardDark.opacity(0.5))
        .cornerRadius(12)
    }
    
    private func incomeCategoryRow(for category: ExpenseCategory, isLast: Bool) -> some View {
        VStack {
            HStack {
                Circle()
                    .fill(category.color)
                    .frame(width: 12, height: 12)
                
                Text(category.name)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                categoryIncomeText(category: category)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            if !isLast {
                Divider()
                    .background(Color.gray.opacity(0.2))
                    .padding(.leading, 30)
            }
        }
    }
    
    private func categoryIncomeText(category: ExpenseCategory) -> some View {
        Text("₺\(Int(category.monthlyIncome ?? 0))")
            .font(.subheadline)
            .foregroundColor(AppColors.income)
            .frame(width: 80)
    }
    
    // ExpenseCategoriesSummaryView Başlangıç
    @ViewBuilder
    private func expenseCategoriesSummaryView(showTable: Bool = true) -> some View {
        let expenseCategories = categories.filter { !$0.isIncome && $0.monthlySpent != nil && $0.monthlySpent! > 0 }
        let sortedExpenseCategories = expenseCategories.sorted { ($0.monthlySpent ?? 0) > ($1.monthlySpent ?? 0) }
        let totalMonthlySpent = expenseCategories.reduce(0) { $0 + ($1.monthlySpent ?? 0) }
        
        let chartSegments = expenseCategories.map { category in
            ChartSegment(
                name: category.name,
                value: category.monthlySpent ?? 0,
                color: category.color
            )
        }.sorted { $0.value > $1.value }
        
        VStack(spacing: 20) {
            // Başlık
            HStack {
                Text("Harcama Dağılımı")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                Text("Bu Ay")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryTextDark)
            }
            .padding(.horizontal)
            
            // Donut Chart
            if chartSegments.isEmpty {
                Text("Henüz harcama verisi yok")
                    .foregroundColor(AppColors.secondaryTextDark)
                    .padding(.vertical, 40)
            } else {
                DonutChartView(
                    segments: chartSegments,
                    width: 220,
                    title: "₺\(Int(totalMonthlySpent))",
                    subtitle: "Toplam"
                )
                .padding(.vertical, 10)
            }
            
            // Harcama Kategorileri Tablosu - Eğer showTable true ise ve veri varsa
            if showTable && !expenseCategories.isEmpty {
                categoriesTable(sortedExpenseCategories: sortedExpenseCategories)
            }
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(12)
    }
    
    private func categoriesTable(sortedExpenseCategories: [ExpenseCategory]) -> some View {
        VStack(spacing: 10) {
            // Kategori tablosu başlığı
            HStack {
                Text("Kategori Detayları")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 5)
            
            // Başlık satırı
            HStack {
                Text("Kategori")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryTextDark)
                
                Spacer()
                
                Text("Bütçe")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryTextDark)
                
                Text("Harcama")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryTextDark)
                    .frame(width: 80)
            }
            .padding(.horizontal)
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // Kategori satırları (maksimum 4 göster)
            ForEach(0..<min(sortedExpenseCategories.count, 4), id: \.self) { index in
                let category = sortedExpenseCategories[index]
                let isLast = index == min(sortedExpenseCategories.count, 4) - 1
                categoryRow(for: category, isLast: isLast)
            }
            
            // 4'ten fazla kategori varsa "Tümünü görüntüle" butonu göster
            if sortedExpenseCategories.count > 4 {
                Button(action: {
                    // Kategori detayları ekranına git butonu
                }) {
                    Text("Tüm kategorileri görüntüle (\(sortedExpenseCategories.count))")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryBlue)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(.vertical, 8)
        .background(AppColors.cardDark.opacity(0.5))
        .cornerRadius(12)
    }
    
    private func categoryRow(for category: ExpenseCategory, isLast: Bool) -> some View {
        VStack {
            HStack {
                Circle()
                    .fill(category.color)
                    .frame(width: 12, height: 12)
                
                Text(category.name)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                categoryBudgetText(category: category)
                
                categorySpentText(category: category)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            if !isLast {
                Divider()
                    .background(Color.gray.opacity(0.2))
                    .padding(.leading, 30)
            }
        }
    }
    
    private func categoryBudgetText(category: ExpenseCategory) -> some View {
        Group {
            if let budget = category.monthlyBudget {
                Text("₺\(Int(budget))")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textDark)
            } else {
                Text("-")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryTextDark)
            }
        }
    }
    
    private func categorySpentText(category: ExpenseCategory) -> some View {
        let spent = category.monthlySpent ?? 0
        let budget = category.monthlyBudget ?? Double.infinity
        let isOverBudget = spent > budget
        
        return Text("₺\(Int(spent))")
            .font(.subheadline)
            .foregroundColor(isOverBudget ? AppColors.expense : AppColors.textDark)
            .frame(width: 80)
    }
    
    // Alt segmentler için tab view
    private func periodTabView(options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<options.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(options[index])
                                .font(.callout)
                                .foregroundColor(selectedTab == index ? .white : AppColors.secondaryTextDark)
                            
                            if selectedTab == index {
                                Rectangle()
                                    .fill(AppColors.primaryBlue)
                                    .frame(height: 3)
                                    .matchedGeometryEffect(id: "tab_indicator", in: animation)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
}

// Sayfa
enum AnalysisPage: CaseIterable {
    case expense
    case income
    
    var title: String {
        switch self {
        case .expense:
            return "Harcamalar"
        case .income:
            return "Gelirler"
        }
    }
    
    var icon: String {
        switch self {
        case .expense:
            return "arrow.down"
        case .income:
            return "arrow.up"
        }
    }
}

struct CategoryBubble: View {
    let category: ExpenseCategory
    
    private var spentPercentage: Double {
        guard let spent = category.monthlySpent, 
              let budget = category.monthlyBudget,
              budget > 0 else { 
            return 0 
        }
        return min(spent / budget, 1.0)
    }
    
    private var isOverBudget: Bool {
        guard let spent = category.monthlySpent, 
              let budget = category.monthlyBudget else { 
            return false 
        }
        return spent > budget
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // İkon ve harcama yüzdesi
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: CGFloat(spentPercentage))
                    .stroke(isOverBudget ? AppColors.expense : category.color, lineWidth: 5)
                    .frame(width: 55, height: 55)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(category.color)
            }
            
            // Kategori ismi ve harcama miktarı
            VStack(spacing: 2) {
                Text(category.name)
                    .font(.caption)
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(1)
                
                if let spent = category.monthlySpent {
                    Text("₺\(Int(spent))")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(isOverBudget ? AppColors.expense : AppColors.textDark)
                }
            }
        }
        .frame(width: 75)
    }
}

struct IncomeCategoryBubble: View {
    let category: ExpenseCategory
    
    var body: some View {
        VStack(spacing: 8) {
            // İkon
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Circle()
                    .stroke(category.color, lineWidth: 5)
                    .frame(width: 55, height: 55)
                
                Image(systemName: category.icon)
                    .font(.system(size: 22))
                    .foregroundColor(category.color)
            }
            
            // Kategori ismi ve gelir miktarı
            VStack(spacing: 2) {
                Text(category.name)
                    .font(.caption)
                    .foregroundColor(AppColors.textDark)
                    .lineLimit(1)
                
                if let income = category.monthlyIncome {
                    Text("₺\(Int(income))")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.income)
                }
            }
        }
        .frame(width: 75)
    }
}

enum AnalysisPeriod: String, CaseIterable, Identifiable {
    case weekly = "Haftalık"
    case monthly = "Aylık"
    case yearly = "Yıllık"
    
    var id: String { self.rawValue }
}

#Preview {
    AnalysisTabView()
}
