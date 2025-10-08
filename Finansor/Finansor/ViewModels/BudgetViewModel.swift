import Foundation
import SwiftUI
import Combine

class BudgetViewModel: ObservableObject {
    @Published var budgets: [FinansorBudget] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var transactionViewModel: TransactionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(transactionViewModel: TransactionViewModel) {
        self.transactionViewModel = transactionViewModel
        
        // Load sample budgets for demo
        loadSampleBudgets()
        
        // Subscribe to transaction changes to update budget spending
        transactionViewModel.$transactions
            .sink { [weak self] transactions in
                self?.updateBudgetSpending(with: transactions)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    // Add budget
    func addBudget(_ budget: FinansorBudget) {
        budgets.append(budget)
        updateBudgetSpending(for: budget.id)
    }
    
    // Update budget
    func updateBudget(_ budget: FinansorBudget) {
        if let index = budgets.firstIndex(where: { $0.id.uuidString == budget.id.uuidString }) {
            budgets[index] = budget
        }
    }
    
    // Delete budget
    func deleteBudget(withId id: UUID) {
        budgets.removeAll { $0.id.uuidString == id.uuidString }
    }
    
    // Get active budgets (current date is within start and end date)
    func getActiveBudgets() -> [FinansorBudget] {
        let now = Date()
        return budgets.filter { $0.startDate <= now && $0.endDate >= now }
    }
    
    // MARK: - Private Methods
    
    // Update spending for a specific budget
    private func updateBudgetSpending(for budgetId: UUID) {
        guard let index = budgets.firstIndex(where: { $0.id.uuidString == budgetId.uuidString }) else { return }
        
        let budget = budgets[index]
        let transactions = transactionViewModel.transactions
        
        // Filter transactions that match the budget's category and date range
        let relevantTransactions = transactions.filter { transaction in
            guard !transaction.isIncome else { return false }
            guard let category = transaction.category else { return false }
            let categoryMatch = budget.category.rawValue == category.name
            let dateMatch = transaction.date >= budget.startDate && transaction.date <= budget.endDate
            return categoryMatch && dateMatch
        }
        
        // Calculate the total spent
        let totalSpent = relevantTransactions.reduce(0) { $0 + $1.amount }
        
        // Update the budget
        var updatedBudget = budget
        updatedBudget.spent = totalSpent
        budgets[index] = updatedBudget
    }
    
    // Update spending for all budgets based on transactions
    private func updateBudgetSpending(with transactions: [FinansorTransaction]) {
        for budget in budgets {
            updateBudgetSpending(for: budget.id)
        }
    }
    
    // Load sample budgets for demo
    private func loadSampleBudgets() {
        let now = Date()
        let calendar = Calendar.current
        
        // Calculate start of month
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        // Calculate end of month
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        let endOfMonth = calendar.date(byAdding: .day, value: -1, to: nextMonth)!
        
        // Sample budgets
        let sampleBudgets: [FinansorBudget] = [
            FinansorBudget(
                name: "Aylık Yemek Bütçesi",
                amount: 1500,
                spent: 750,
                category: .food,
                period: .monthly,
                startDate: startOfMonth,
                endDate: endOfMonth
            ),
            FinansorBudget(
                name: "Ulaşım Bütçesi",
                amount: 800,
                spent: 430,
                category: .transportation,
                period: .monthly,
                startDate: startOfMonth,
                endDate: endOfMonth
            ),
            FinansorBudget(
                name: "Eğlence Harcamaları",
                amount: 1000,
                spent: 480,
                category: .entertainment,
                period: .monthly,
                startDate: startOfMonth,
                endDate: endOfMonth
            ),
            FinansorBudget(
                name: "Faturalar",
                amount: 1200,
                spent: 950,
                category: .utilities,
                period: .monthly,
                startDate: startOfMonth,
                endDate: endOfMonth
            )
        ]
        
        budgets = sampleBudgets
    }
} 