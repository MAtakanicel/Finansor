import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    @EnvironmentObject private var budgetViewModel: BudgetViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                FinansorColors.backgroundDark.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Merhaba,")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(userViewModel.currentUser?.name ?? "Kullanıcı")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Profile avatar
                        Circle()
                            .fill(FinansorColors.accentYellow)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(userViewModel.currentUser?.name.prefix(1).uppercased() ?? "U")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(FinansorColors.backgroundDark)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Summary cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // Balance card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Kalan Bakiye")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("₺\(Int(transactionViewModel.totalIncome() - transactionViewModel.totalExpense()))")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Gelir")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text("₺\(Int(transactionViewModel.totalIncome()))")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Gider")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text("₺\(Int(transactionViewModel.totalExpense()))")
                                            .font(.headline)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding()
                            .frame(width: 300, height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(FinansorColors.accentBlue)
                            )
                            
                            // Budget card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Aylık Bütçe")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("Aktif Bütçeler")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(budgetViewModel.getActiveBudgets().count) aktif bütçe")
                                    .font(.callout)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .frame(width: 200, height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(FinansorColors.primaryBlue)
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent transactions header
                    HStack {
                        Text("Son İşlemler")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            // Show all transactions
                        }) {
                            Text("Tümünü Gör")
                                .font(.subheadline)
                                .foregroundColor(FinansorColors.accentYellow)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Recent transactions list
                    if transactionViewModel.transactions.isEmpty {
                        Spacer()
                        
                        Text("Henüz işlem bulunmuyor")
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                        
                        Spacer()
                    } else {
                        List {
                            ForEach(transactionViewModel.transactions.prefix(5)) { transaction in
                                HStack {
                                    // Category icon
                                    ZStack {
                                        Circle()
                                            .fill(transaction.category?.color ?? Color.gray)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: transaction.category?.icon ?? "questionmark")
                                            .foregroundColor(.white)
                                    }
                                    
                                    // Transaction details
                                    VStack(alignment: .leading) {
                                        Text(transaction.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text(transaction.shortFormattedDate)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    // Amount
                                    Text(transaction.isIncome ? "+\(transaction.formattedAmount) ₺" : "-\(transaction.formattedAmount) ₺")
                                        .font(.headline)
                                        .foregroundColor(transaction.isIncome ? .green : .red)
                                }
                                .padding(.vertical, 4)
                                .listRowBackground(FinansorColors.backgroundDark)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(FinansorColors.backgroundDark)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    HomeTabView()
        .environmentObject(UserViewModel())
        .environmentObject(TransactionViewModel(categoryViewModel: CategoryViewModel()))
        .environmentObject(BudgetViewModel(transactionViewModel: TransactionViewModel(categoryViewModel: CategoryViewModel())))
}
