import Foundation
import SwiftUI
import Combine

class CategoryViewModel: ObservableObject {
    @Published var expenseCategories: [FinansorExpenseCategory] = []
    @Published var incomeCategories: [FinansorExpenseCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var allCategories: [FinansorExpenseCategory] {
        expenseCategories + incomeCategories
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let storageService = DataStorageService.shared
    
    init() {
        // Kaydedilmiş kategorileri yüklemeyi dene, yoksa varsayılanları yükle
        if let saved: [FinansorExpenseCategory] = storageService.load(forKey: .categories) {
            // Kaydedilmiş kategorileri gelir/gider olarak ayır
            let incomes = saved.filter { $0.isIncome }
            let expenses = saved.filter { !$0.isIncome }
            incomeCategories = incomes
            expenseCategories = expenses
        } else {
            loadDefaultCategories()
        }
        
        // Kategorilerde değişiklik olduğunda kaydet
        Publishers.CombineLatest($expenseCategories, $incomeCategories)
            .sink { [weak self] (expenses, incomes) in
                self?.saveCategories(all: expenses + incomes)
            }
            .store(in: &cancellables)
    }
    
    // Kategorileri gelir ve gider olarak ayır
    private func updateSeparatedLists(allCategories: [FinansorExpenseCategory]) {
        incomeCategories = allCategories.filter { $0.isIncome }
        let expenses = allCategories.filter { !$0.isIncome }
        
        // Sadece gider kategorilerini güncelle, diğerlerini koru
        if expenseCategories != expenses {
            expenseCategories = expenses
        }
    }
    
    // Kategorileri kaydet
    private func saveCategories(all: [FinansorExpenseCategory]) {
        storageService.save(all, forKey: .categories)
    }
    
    // MARK: - Public Methods
    
    // Add category
    func addCategory(_ category: FinansorExpenseCategory) {
        if category.isIncome {
            incomeCategories.append(category)
        } else {
            expenseCategories.append(category)
        }
    }

    // Set monthly income for salary category and reset others
    func setSalaryMonthlyIncome(_ amount: Double) {
        // Update salary category (Maaş)
        if let index = incomeCategories.firstIndex(where: { $0.name == FinansorCategoryType.salary.rawValue }) {
            var salary = incomeCategories[index]
            salary.monthlyIncome = amount
            incomeCategories[index] = salary
        } else if !incomeCategories.isEmpty {
            // Fallback: set first income category
            var first = incomeCategories[0]
            first.monthlyIncome = amount
            incomeCategories[0] = first
        }
        
        // Reset other income categories to avoid double counting
        for i in 0..<incomeCategories.count {
            if incomeCategories[i].name != FinansorCategoryType.salary.rawValue {
                incomeCategories[i].monthlyIncome = 0
            }
        }
    }
    
    // Update category
    func updateCategory(_ category: FinansorExpenseCategory) {
        if category.isIncome {
            if let index = incomeCategories.firstIndex(where: { $0.id.uuidString == category.id.uuidString }) {
                incomeCategories[index] = category
            }
        } else {
            if let index = expenseCategories.firstIndex(where: { $0.id.uuidString == category.id.uuidString }) {
                expenseCategories[index] = category
            }
        }
    }
    
    // Delete category
    func deleteCategory(withId id: UUID) {
        expenseCategories.removeAll { $0.id.uuidString == id.uuidString }
        incomeCategories.removeAll { $0.id.uuidString == id.uuidString }
    }
    
    // Get category by ID
    func getCategory(withId id: UUID) -> FinansorExpenseCategory? {
        return allCategories.first { $0.id.uuidString == id.uuidString }
    }
    
    // Update category spending
    func updateCategorySpending(categoryId: UUID, amount: Double, isIncome: Bool) {
        if isIncome {
            if let index = incomeCategories.firstIndex(where: { $0.id.uuidString == categoryId.uuidString }) {
                var category = incomeCategories[index]
                category.monthlyIncome = (category.monthlyIncome ?? 0) + amount
                incomeCategories[index] = category
            }
        } else {
            if let index = expenseCategories.firstIndex(where: { $0.id.uuidString == categoryId.uuidString }) {
                var category = expenseCategories[index]
                category.monthlySpent = (category.monthlySpent ?? 0) + amount
                expenseCategories[index] = category
            }
        }
    }
    
    // MARK: - Private Methods
    
    // Load default categories
    private func loadDefaultCategories() {
        // Expense categories
        let defaultExpenseCategories: [FinansorExpenseCategory] = [
            FinansorExpenseCategory(
                name: "Yemek",
                icon: FinansorCategoryType.food.icon,
                color: FinansorCategoryType.food.color,
                isIncome: false,
                isSystem: true,
                monthlyBudget: 1500,
                monthlySpent: 0
            ),
            FinansorExpenseCategory(
                name: "Ulaşım",
                icon: FinansorCategoryType.transportation.icon,
                color: FinansorCategoryType.transportation.color,
                isIncome: false,
                isSystem: true,
                monthlyBudget: 800,
                monthlySpent: 0
            ),
            FinansorExpenseCategory(
                name: "Alışveriş",
                icon: FinansorCategoryType.shopping.icon,
                color: FinansorCategoryType.shopping.color,
                isIncome: false,
                isSystem: true,
                monthlyBudget: 1000,
                monthlySpent: 0
            ),
            FinansorExpenseCategory(
                name: "Eğlence",
                icon: FinansorCategoryType.entertainment.icon,
                color: FinansorCategoryType.entertainment.color,
                isIncome: false,
                isSystem: true,
                monthlyBudget: 500,
                monthlySpent: 0
            ),
            FinansorExpenseCategory(
                name: "Faturalar",
                icon: FinansorCategoryType.utilities.icon,
                color: FinansorCategoryType.utilities.color,
                isIncome: false,
                isSystem: true,
                monthlyBudget: 1200,
                monthlySpent: 0
            ),
            FinansorExpenseCategory(
                name: "Konut",
                icon: FinansorCategoryType.housing.icon,
                color: FinansorCategoryType.housing.color,
                isIncome: false,
                isSystem: true,
                monthlyBudget: 3500,
                monthlySpent: 0
            ),
            FinansorExpenseCategory(
                name: "Sağlık",
                icon: FinansorCategoryType.health.icon,
                color: FinansorCategoryType.health.color,
                isIncome: false,
                isSystem: true,
                monthlyBudget: 600,
                monthlySpent: 0
            ),
            FinansorExpenseCategory(
                name: "Diğer",
                icon: FinansorCategoryType.other.icon,
                color: FinansorCategoryType.other.color,
                isIncome: false,
                isSystem: true,
                monthlyBudget: 500,
                monthlySpent: 0
            )
        ]
        
        // Income categories
        let defaultIncomeCategories: [FinansorExpenseCategory] = [
            FinansorExpenseCategory(
                name: "Maaş",
                icon: FinansorCategoryType.salary.icon,
                color: FinansorCategoryType.salary.color,
                isIncome: true,
                isSystem: true,
                monthlyIncome: 0
            ),
            FinansorExpenseCategory(
                name: "Yatırım",
                icon: FinansorCategoryType.investment.icon,
                color: FinansorCategoryType.investment.color,
                isIncome: true,
                isSystem: true,
                monthlyIncome: 0
            ),
            FinansorExpenseCategory(
                name: "Hediye",
                icon: FinansorCategoryType.gift.icon,
                color: FinansorCategoryType.gift.color,
                isIncome: true,
                isSystem: true,
                monthlyIncome: 0
            ),
            FinansorExpenseCategory(
                name: "Diğer Gelir",
                icon: FinansorCategoryType.otherIncome.icon,
                color: FinansorCategoryType.otherIncome.color,
                isIncome: true,
                isSystem: true,
                monthlyIncome: 0
            )
        ]
        
        expenseCategories = defaultExpenseCategories
        incomeCategories = defaultIncomeCategories
    }
} 