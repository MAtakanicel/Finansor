import SwiftUI

struct AnalysisTabView: View {
    @EnvironmentObject private var analysisViewModel: AnalysisViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                FinansorColors.backgroundDark.ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("Analiz")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Period selection
                    Picker("Dönem", selection: $analysisViewModel.selectedPeriod) {
                        ForEach(FinansorAnalysisPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Type selection
                    Picker("Tür", selection: $analysisViewModel.selectedPage) {
                        ForEach(FinansorAnalysisPage.allCases) { page in
                            Text(page.rawValue).tag(page)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    if let summary = analysisViewModel.analysisSummary {
                        ScrollView {
                            VStack(spacing: 16) {
                                // Summary cards
                                HStack(spacing: 12) {
                                    // Income Card
                                    VStack(alignment: .leading) {
                                        Text("Gelir")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Text(summary.formattedTotalIncome)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(10)
                                    
                                    // Expense Card
                                    VStack(alignment: .leading) {
                                        Text("Gider")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Text(summary.formattedTotalExpense)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.red.opacity(0.2))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                
                                // Display chart based on the selected page
                                if analysisViewModel.selectedPage == .expense {
                                    Text("Giderler")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    DonutChartView(
                                        segments: analysisViewModel.expenseByCategory(),
                                        width: 260,
                                        innerRadiusFraction: 0.62,
                                        title: summary.formattedTotalExpense,
                                        subtitle: summary.period
                                    )
                                    .padding(.horizontal)
                                } else {
                                    Text("Gelirler")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    DonutChartView(
                                        segments: analysisViewModel.incomeByCategory(),
                                        width: 260,
                                        innerRadiusFraction: 0.62,
                                        title: summary.formattedTotalIncome,
                                        subtitle: summary.period
                                    )
                                    .padding(.horizontal)
                                }
                                
                                Spacer()
                            }
                            .padding(.top)
                        }
                    } else {
                        Spacer()
                        
                        Text("Veri bulunamadı")
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AnalysisTabView()
        .environmentObject(AnalysisViewModel(
            transactionViewModel: TransactionViewModel(categoryViewModel: CategoryViewModel()),
            categoryViewModel: CategoryViewModel()
        ))
}
