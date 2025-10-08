import SwiftUI
import Combine

class TransactionViewModel: ObservableObject {
    @Published var transactions: [FinansorTransaction] = []
    @Published var filteredTransactions: [FinansorTransaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var selectedMonth: Date = Date()
    
    private var categoryViewModel: CategoryViewModel
    private var cancellables = Set<AnyCancellable>()
    private let storageService = DataStorageService.shared
    
    init(categoryViewModel: CategoryViewModel) {
        self.categoryViewModel = categoryViewModel
        
        // Kaydedilmiş işlemleri yüklemeyi dene
        if var savedTransactions: [FinansorTransaction] = storageService.load(forKey: .transactions) {
            // Kaydedilmiş işlemlere kategori referanslarını ekle
            for i in 0..<savedTransactions.count {
                if let category = categoryViewModel.expenseCategories.first(where: { $0.id.uuidString == savedTransactions[i].categoryId.uuidString }) {
                    savedTransactions[i].category = category
                }
            }
            transactions = savedTransactions
        } else {
            // Kaydedilmiş işlem yoksa örnek verileri yükle
            loadSampleTransactions()
        }
        
        // Transactions değiştiğinde filtrelenmiş listeyi güncelle ve verileri kaydet
        $transactions
            .sink { [weak self] transactions in
                self?.filteredTransactions = transactions
                self?.saveTransactions()
            }
            .store(in: &cancellables)
        
        // Set up search filter
        $searchText
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.filterTransactions(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    // İşlemleri kaydet
    private func saveTransactions() {
        storageService.save(transactions, forKey: .transactions)
    }
    
    // MARK: - Public Methods
    
    // Yeni işlem ekle
    func addTransaction(_ transaction: FinansorTransaction) {
        transactions.append(transaction)
        sortTransactions()
        updateCategorySpending(transaction)
    }
    
    // İşlem güncelle
    func updateTransaction(_ transaction: FinansorTransaction) {
        if let index = transactions.firstIndex(where: { $0.id.uuidString == transaction.id.uuidString }) {
            let oldTransaction = transactions[index]
            
            // Eski işlemi harcama kategorisinden çıkar
            if !oldTransaction.isIncome, let oldCategory = oldTransaction.category {
                subtractFromCategorySpending(oldTransaction)
            }
            
            // Yeni işlemi ekle
            transactions[index] = transaction
            
            // Yeni işlemi kategori harcamasına ekle
            if !transaction.isIncome {
                updateCategorySpending(transaction)
            }
        }
    }
    
    // İşlem sil
    func deleteTransaction(at indexSet: IndexSet) {
        transactions.remove(atOffsets: indexSet)
    }
    
    // İşlem sil
    func deleteTransaction(withId id: UUID) {
        if let index = transactions.firstIndex(where: { $0.id.uuidString == id.uuidString }) {
            transactions.remove(at: index)
        }
    }
    
    // İşlemleri filtrele
    func filterTransactions(byCategory categoryId: UUID? = nil, isIncome: Bool? = nil, dateRange: ClosedRange<Date>? = nil) {
        filteredTransactions = transactions.filter { transaction in
            var matches = true
            
            // Kategori filtresi
            if let categoryId = categoryId, let transCategoryId = transaction.category?.id {
                matches = matches && transCategoryId.uuidString == categoryId.uuidString
            }
            
            // Gelir/gider filtresi
            if let isIncome = isIncome {
                matches = matches && transaction.isIncome == isIncome
            }
            
            // Tarih aralığı filtresi
            if let dateRange = dateRange {
                matches = matches && dateRange.contains(transaction.date)
            }
            
            return matches
        }
    }
    
    // Belirli bir dönem için toplam gelir
    func totalIncome(for period: ClosedRange<Date>? = nil) -> Double {
        let filtered = period == nil ? transactions : transactions.filter { transaction in
            if let range = period {
                return range.contains(transaction.date)
            }
            return true
        }
        
        return filtered.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    // Belirli bir dönem için toplam gider
    func totalExpense(for period: ClosedRange<Date>? = nil) -> Double {
        let filtered = period == nil ? transactions : transactions.filter { transaction in
            if let range = period {
                return range.contains(transaction.date)
            }
            return true
        }
        
        return filtered.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Private Methods
    
    // Kategori harcamasını güncelle
    private func updateCategorySpending(_ transaction: FinansorTransaction) {
        guard !transaction.isIncome, let category = transaction.category else { return }
        
        // İlgili kategoriyi bul ve güncelle
        var updatedCategory = category
        updatedCategory.monthlySpent = (updatedCategory.monthlySpent ?? 0) + transaction.amount
        categoryViewModel.updateCategory(updatedCategory)
    }
    
    // Kategori harcamasından çıkar
    private func subtractFromCategorySpending(_ transaction: FinansorTransaction) {
        guard !transaction.isIncome, let category = transaction.category else { return }
        
        // İlgili kategoriyi bul ve güncelle
        var updatedCategory = category
        updatedCategory.monthlySpent = max((updatedCategory.monthlySpent ?? 0) - transaction.amount, 0)
        categoryViewModel.updateCategory(updatedCategory)
    }
    
    // Sort transactions by date (newest first)
    private func sortTransactions() {
        transactions.sort { $0.date > $1.date }
        filterTransactions(searchText: searchText)
    }
    
    // Filter transactions based on search text
    private func filterTransactions(searchText: String) {
        if searchText.isEmpty {
            filteredTransactions = transactions
        } else {
            filteredTransactions = transactions.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.category?.name.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
    
    // MARK: - Sample Data
    
    // Örnek verileri yükle
    private func loadSampleTransactions() {
        let now = Date()
        
        guard let incomeCategory = categoryViewModel.expenseCategories.first(where: { $0.isIncome }) else { return }
        guard let expenseCategory = categoryViewModel.expenseCategories.first(where: { !$0.isIncome }) else { return }
        
        transactions = [
            FinansorTransaction(
                title: "Maaş",
                amount: 20000,
                date: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now,
                categoryId: incomeCategory.id,
                category: incomeCategory,
                isIncome: true
            ),
            FinansorTransaction(
                title: "Fatura Ödemesi",
                amount: 810,
                date: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now,
                categoryId: expenseCategory.id,
                category: expenseCategory,
                isIncome: false
            ),
            FinansorTransaction(
                title: "Kira",
                amount: 9500,
                date: Calendar.current.date(byAdding: .day, value: -4, to: now) ?? now,
                categoryId: expenseCategory.id,
                category: expenseCategory,
                isIncome: false
            )
        ]
        
        // Örnek verileri hemen kaydet
        saveTransactions()
    }
} 