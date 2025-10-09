import SwiftUI

struct DebugTestsView: View {
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    @State private var resultText: String = "Henüz test çalıştırılmadı"
    @State private var resultColor: Color = .gray
    
    private var totalIncomeSum: Double {
        categoryViewModel.incomeCategories.reduce(0) { $0 + ($1.monthlyIncome ?? 0) }
    }
    
    private var salaryIncome: Double {
        categoryViewModel.incomeCategories.first(where: { $0.name == FinansorCategoryType.salary.rawValue })?.monthlyIncome ?? 0
    }
    
    private var otherIncomeSum: Double {
        categoryViewModel.incomeCategories.filter { $0.name != FinansorCategoryType.salary.rawValue }.reduce(0) { $0 + ($1.monthlyIncome ?? 0) }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Debug Testleri")
                .font(.title2)
                .foregroundColor(.white)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Toplam Gelir: \(Int(totalIncomeSum))")
                    .foregroundColor(.white)
                Text("Maaş Geliri: \(Int(salaryIncome))")
                    .foregroundColor(.white)
                Text("Diğer Gelirler Toplamı: \(Int(otherIncomeSum))")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(AppColors.cardDark)
            .cornerRadius(12)
            
            Button(action: runSalary25Test) {
                Text("Test: Maaş = 25 TL")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primaryBlue)
                    .cornerRadius(10)
            }
            
            Button(action: runRepeatIdempotentTest) {
                Text("Tekrar Testi: Maaş = 25 TL (idempotent)")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.accentYellow)
                    .cornerRadius(10)
            }
            
            Button(action: resetIncomes) {
                Text("Sıfırla (Maaş = 0)")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.expense)
                    .cornerRadius(10)
            }
            
            Text(resultText)
                .foregroundColor(resultColor)
                .padding(.top, 8)
            
            Spacer()
        }
        .padding()
        .background(AppColors.backgroundDark.ignoresSafeArea())
    }
    
    private func runSalary25Test() {
        categoryViewModel.setSalaryMonthlyIncome(25)
        validate(expected: 25)
    }
    
    private func runRepeatIdempotentTest() {
        // Aynı değeri tekrar uygular; toplam yine 25 kalmalı
        categoryViewModel.setSalaryMonthlyIncome(25)
        validate(expected: 25)
    }
    
    private func resetIncomes() {
        categoryViewModel.setSalaryMonthlyIncome(0)
        validate(expected: 0)
    }
    
    private func validate(expected: Double) {
        let ok = abs(totalIncomeSum - expected) < 0.0001 && abs(salaryIncome - expected) < 0.0001 && abs(otherIncomeSum - 0) < 0.0001
        if ok {
            resultText = "Başarılı: Toplam=\(Int(totalIncomeSum)), Maaş=\(Int(salaryIncome)), Diğer=\(Int(otherIncomeSum))"
            resultColor = .green
        } else {
            resultText = "Hata: Toplam=\(Int(totalIncomeSum)), Maaş=\(Int(salaryIncome)), Diğer=\(Int(otherIncomeSum)) (Beklenen: \(Int(expected)), 0, 0)"
            resultColor = .red
        }
    }
}

#Preview {
    DebugTestsView()
        .environmentObject(CategoryViewModel())
}


