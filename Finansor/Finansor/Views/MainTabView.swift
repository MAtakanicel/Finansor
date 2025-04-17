import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
           
                HomeTabView()
            .tabItem {
                Image(systemName: "house.fill")
                Text("Ana Sayfa")
            }
            .tag(0)
            
                TransactionTabView()
            .tabItem {
                Image(systemName: "arrow.left.arrow.right")
                Text("İşlemler")
            }
            .tag(1)
                
                CameraTabView()
            .tabItem {
                Image(systemName: "camera.fill")
            }.tag(2)
            
                AnalysisTabView()
            .tabItem {
                Image(systemName: "doc.text.magnifyingglass")
                Text("Analiz")
            }
            .tag(3)
            
                SettingsTabView()
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Ayarlar")
            }
            .tag(4)
            
          
            
        }
        .accentColor(AppColors.accentYellow)
        .onAppear {
            // Tab bar görünümünü özelleştir
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor(AppColors.backgroundDark)
            
            // Seçili olmayan tab'ların rengini ayarla
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
            
            // Seçili tab'ın rengini ayarla
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.accentYellow)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppColors.accentYellow)]
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    MainTabView()
}
