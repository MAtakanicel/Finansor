//
//  FinansorApp.swift
//  Finansor
//
//  Created by Atakan İçel on 26.03.2025.
//

import SwiftUI

// These are commented out since we're now using the direct models instead of conversion
/*
// Tip dönüşümleri için global extension
extension FinansorExpenseCategory {
    // Geriye dönük uyumluluk sağlamak için dönüşüm fonksiyonu
    static func from(_ entity: ExpenseCategory) -> FinansorExpenseCategory {
        return FinansorExpenseCategory(
            id: entity.id,
            name: entity.name,
            icon: entity.icon,
            color: entity.color,
            isIncome: entity.isIncome,
            isSystem: entity.isSystem,
            monthlyBudget: entity.monthlyBudget,
            monthlySpent: entity.monthlySpent,
            monthlyIncome: entity.monthlyIncome
        )
    }
}

extension FinansorTransaction {
    // Geriye dönük uyumluluk sağlamak için dönüşüm fonksiyonu
    static func from(_ entity: Transaction) -> FinansorTransaction {
        return FinansorTransaction(
            id: entity.id,
            title: entity.title,
            amount: entity.amount,
            date: entity.date,
            categoryId: entity.categoryId,
            category: entity.category.map(FinansorExpenseCategory.from),
            isIncome: entity.isIncome,
            notes: entity.notes
        )
    }
}

extension FinansorBudget {
    // Geriye dönük uyumluluk sağlamak için dönüşüm fonksiyonu
    static func from(_ entity: Budget) -> FinansorBudget {
        return FinansorBudget(
            id: entity.id,
            name: entity.name, 
            amount: entity.amount,
            spent: entity.spent,
            category: FinansorBudgetCategory(rawValue: entity.category.rawValue) ?? .other,
            period: FinansorBudgetPeriod(rawValue: entity.period.rawValue) ?? .monthly,
            startDate: entity.startDate,
            endDate: entity.endDate
        )
    }
}
*/

// Remove TransactionModels and BudgetModels from the project
// and use the main models instead. This eliminates duplicate definitions.

// Register namespace for component organization
enum RegisterViews {}

@main
struct FinansorApp: App {
    // MARK: - View Models
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    
    // Diğer ViewModels'lar arasındaki bağımlılıkları oluşturabilmek için onları lazy var olarak tanımlıyoruz
    @StateObject private var transactionViewModel: TransactionViewModel
    @StateObject private var budgetViewModel: BudgetViewModel
    @StateObject private var analysisViewModel: AnalysisViewModel
    
    init() {
        // ViewModel'lar arasındaki bağımlılıkları oluştur
        let categoryVM = CategoryViewModel()
        
        let transactionVM = TransactionViewModel(categoryViewModel: categoryVM)
        let budgetVM = BudgetViewModel(transactionViewModel: transactionVM)
        let analysisVM = AnalysisViewModel(
            transactionViewModel: transactionVM,
            categoryViewModel: categoryVM
        )
        
        // StateObjects'leri başlat
        _categoryViewModel = StateObject(wrappedValue: categoryVM)
        _transactionViewModel = StateObject(wrappedValue: transactionVM)
        _budgetViewModel = StateObject(wrappedValue: budgetVM)
        _analysisViewModel = StateObject(wrappedValue: analysisVM)
    }
    
    var body: some Scene {
        WindowGroup {
            // Kullanıcı oturum durumuna göre ekran gösterimi
            Group {
                if userViewModel.isAuthenticated {
                    MainTabView()
                        .environmentObject(userViewModel)
                        .environmentObject(categoryViewModel)
                        .environmentObject(transactionViewModel)
                        .environmentObject(budgetViewModel)
                        .environmentObject(analysisViewModel)
                } else {
                    WelcomeView()
                        .environmentObject(userViewModel)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
