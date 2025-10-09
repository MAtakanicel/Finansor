import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    @EnvironmentObject private var budgetViewModel: BudgetViewModel
    @EnvironmentObject private var analysisViewModel: AnalysisViewModel
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeTabView()
                .environmentObject(userViewModel)
                .environmentObject(transactionViewModel)
                .environmentObject(budgetViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Ana Sayfa")
                }
                .tag(0)
            
            // Transactions Tab
            TransactionTabView()
                .tabItem {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("İşlemler")
                }
                .tag(1)
            
            // Analysis Tab
            AnalysisTabView()
                .environmentObject(analysisViewModel)
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Analiz")
                }
                .tag(2)
            
            // Budget Tab
            BudgetsView()
                .tabItem {
                    Image(systemName: "banknote.fill")
                    Text("Bütçe")
                }
                .tag(3)
            
            // Profile Tab
            SettingsTabView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
                .tag(4)
        }
        .accentColor(FinansorColors.buttonLightBlue)
        .onAppear {
            // Set tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            appearance.backgroundColor = UIColor(Color.black.opacity(0.8))
            
            // Use this appearance when scrolling behind the TabView
            UITabBar.appearance().standardAppearance = appearance
            // Use this appearance when scrolled all the way up
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserViewModel())
        .environmentObject(TransactionViewModel(categoryViewModel: CategoryViewModel()))
        .environmentObject(BudgetViewModel(transactionViewModel: TransactionViewModel(categoryViewModel: CategoryViewModel())))
        .environmentObject(AnalysisViewModel(
            transactionViewModel: TransactionViewModel(categoryViewModel: CategoryViewModel()),
            categoryViewModel: CategoryViewModel())
        )
}
