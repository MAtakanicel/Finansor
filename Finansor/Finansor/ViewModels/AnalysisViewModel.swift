import SwiftUI
import Combine

class AnalysisViewModel: ObservableObject {
    @Published var selectedPeriod: FinansorAnalysisPeriod = .monthly
    @Published var selectedPage: FinansorAnalysisPage = .expense
    @Published var currentTimePeriod: Int = 0 // 0: Bu ay/hafta/yıl, 1: Geçen ay/hafta/yıl, vb.
    @Published var analysisSummary: AnalysisSummary?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var transactionViewModel: TransactionViewModel
    private var categoryViewModel: CategoryViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(transactionViewModel: TransactionViewModel, categoryViewModel: CategoryViewModel) {
        self.transactionViewModel = transactionViewModel
        self.categoryViewModel = categoryViewModel
        
        // İşlemler veya kategoriler değiştiğinde analizi güncelle
        Publishers.CombineLatest3(
            transactionViewModel.$transactions,
            categoryViewModel.$expenseCategories,
            $selectedPeriod
        )
        .debounce(for: 0.3, scheduler: RunLoop.main)
        .sink { [weak self] (_, _, _) in
            self?.generateAnalysis()
        }
        .store(in: &cancellables)
        
        // Seçilen dönem veya sayfa değiştiğinde analizi güncelle
        Publishers.CombineLatest3(
            $selectedPeriod,
            $selectedPage,
            $currentTimePeriod
        )
        .debounce(for: 0.3, scheduler: RunLoop.main)
        .sink { [weak self] (_, _, _) in
            self?.generateAnalysis()
        }
        .store(in: &cancellables)
        
        // Başlangıçta analizi oluştur
        generateAnalysis()
    }
    
    // MARK: - Public Methods
    
    // Analiz sayfasını değiştir (Gelir/Gider)
    func setPage(_ page: FinansorAnalysisPage) {
        selectedPage = page
    }
    
    // Analiz dönemini değiştir (Haftalık/Aylık/Yıllık)
    func setPeriod(_ period: FinansorAnalysisPeriod) {
        selectedPeriod = period
    }
    
    // Zaman dönemini değiştir (Bu ay, Geçen ay, vb.)
    func setTimePeriod(_ periodIndex: Int) {
        currentTimePeriod = periodIndex
    }
    
    // Dönemi ilerlet (sonraki ay/hafta/yıl)
    func goToNextPeriod() {
        currentTimePeriod -= 1
    }
    
    // Dönemi gerilet (önceki ay/hafta/yıl)
    func goToPreviousPeriod() {
        currentTimePeriod += 1
    }
    
    // Kategori başına harcama
    func expenseByCategory() -> [AnalysisChartSegment] {
        return analysisSummary?.expenseCategories ?? []
    }
    
    // Kategori başına gelir
    func incomeByCategory() -> [AnalysisChartSegment] {
        return analysisSummary?.incomeCategories ?? []
    }
    
    // MARK: - Private Methods
    
    // Analiz özeti oluştur
    private func generateAnalysis() {
        isLoading = true
        
        // Seçilen döneme göre tarih aralığını hesapla
        let dateRange = calculateDateRange()
        
        // İşlemleri filtrele
        let filteredTransactions = transactionViewModel.transactions.filter { transaction in
            dateRange.contains(transaction.date)
        }
        
        // Gelir ve gider işlemlerini ayır
        let incomeTransactions = filteredTransactions.filter { $0.isIncome }
        let expenseTransactions = filteredTransactions.filter { !$0.isIncome }
        
        // Toplam gelir ve gider
        let totalIncome = incomeTransactions.reduce(0) { $0 + $1.amount }
        let totalExpense = expenseTransactions.reduce(0) { $0 + $1.amount }
        let netAmount = totalIncome - totalExpense
        
        // Tasarruf oranı
        let savingsPercentage = totalIncome > 0 ? (netAmount / totalIncome) * 100 : 0
        
        // Kategori bazlı gelir segmentleri
        var incomeCategories: [AnalysisChartSegment] = []
        for transaction in incomeTransactions {
            if let category = transaction.category {
                if let index = incomeCategories.firstIndex(where: { $0.name == category.name }) {
                    incomeCategories[index].value += transaction.amount
                } else {
                    incomeCategories.append(AnalysisChartSegment(
                        name: category.name,
                        value: transaction.amount,
                        color: category.color
                    ))
                }
            }
        }
        
        // Kategori bazlı gider segmentleri
        var expenseCategories: [AnalysisChartSegment] = []
        for transaction in expenseTransactions {
            if let category = transaction.category {
                if let index = expenseCategories.firstIndex(where: { $0.name == category.name }) {
                    expenseCategories[index].value += transaction.amount
                } else {
                    expenseCategories.append(AnalysisChartSegment(
                        name: category.name,
                        value: transaction.amount,
                        color: category.color
                    ))
                }
            }
        }
        
        // Dönem adını oluştur
        let periodName = createPeriodName()
        
        // Analiz özetini güncelle
        analysisSummary = AnalysisSummary(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            netAmount: netAmount,
            period: periodName,
            incomeCategories: incomeCategories,
            expenseCategories: expenseCategories,
            savingsPercentage: savingsPercentage
        )
        
        isLoading = false
    }
    
    // Seçilen döneme göre tarih aralığını hesapla
    private func calculateDateRange() -> ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        
        var startDate: Date
        var endDate: Date
        
        switch selectedPeriod {
        case .weekly:
            // Haftalık
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            components.weekOfYear = components.weekOfYear! - currentTimePeriod
            startDate = calendar.date(from: components)!
            endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
            
        case .monthly:
            // Aylık
            var components = calendar.dateComponents([.year, .month], from: now)
            components.month = components.month! - currentTimePeriod
            startDate = calendar.date(from: components)!
            endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
            
        case .yearly:
            // Yıllık
            var components = calendar.dateComponents([.year], from: now)
            components.year = components.year! - currentTimePeriod
            startDate = calendar.date(from: components)!
            endDate = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startDate)!
        }
        
        return startDate...endDate
    }
    
    // Dönem adını oluştur
    private func createPeriodName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        
        let dateRange = calculateDateRange()
        let startDate = dateRange.lowerBound
        
        switch selectedPeriod {
        case .weekly:
            formatter.dateFormat = "d MMM"
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: dateRange.upperBound))"
            
        case .monthly:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: startDate)
            
        case .yearly:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: startDate)
        }
    }
} 