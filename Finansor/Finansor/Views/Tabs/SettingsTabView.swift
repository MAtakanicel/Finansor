import SwiftUI

struct SettingsTabView: View {
    @State private var isDarkMode: Bool = true
    @State private var isNotificationsEnabled: Bool = true
    @State private var selectedCurrency: Currency = .try
    @State private var selectedLanguage: Language = .turkish
    @State private var isBiometricEnabled: Bool = false
    @State private var isPINEnabled: Bool = false
    @State private var showLogoutAlert: Bool = false
    @State private var userName: String = "Atakan"
    @State private var userEmail: String = "icelatakan@gmail.com"
    @State private var userImageName: String = "person.circle.fill"
    @State private var monthlyIncome: Double = 25000
    @State private var showWelcomeView : Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Kullanıcı Profili
                        VStack(spacing: 15) {
                            Image(systemName: userImageName)
                                .font(.system(size: 70))
                                .foregroundColor(AppColors.primaryBlue)
                                .padding()
                                .background(AppColors.primaryBlue.opacity(0.2))
                                .clipShape(Circle())
                            
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textDark)
                            
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryTextDark)
                            
                            Button(action: {
                                // Profili Düzenleme
                            }) {
                                Text("Profili Düzenle (fake)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.primaryBlue)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(AppColors.primaryBlue.opacity(0.1))
                                    .cornerRadius(20)
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Genel Ayarlar
                        SettingsSection(title: "Genel") {
                            // Tema Ayarı
                            SettingsToggleRow(
                                title: "Koyu Mod (fake)",
                                icon: "moon.stars.fill",
                                iconColor: .purple,
                                isOn: $isDarkMode
                            )
                            
                            // Bildirimler
                            SettingsToggleRow(
                                title: "Bildirimler (fake)",
                                icon: "bell.fill",
                                iconColor: .orange,
                                isOn: $isNotificationsEnabled
                            )
                            
                            // Para Birimi
                            SettingsNavigationRow(
                                title: "Para Birimi (fake)",
                                icon: "turkishlirasign.circle.fill",
                                iconColor: .green,
                                value: selectedCurrency.rawValue
                            ) {
                                // Para Birimi Seçim Ekranı
                            }
                            
                            // Dil
                            SettingsNavigationRow(
                                title: "Dil (fake)",
                                icon: "globe",
                                iconColor: .blue,
                                value: selectedLanguage.rawValue
                            ) {
                                // Dil Seçim Ekranı
                            }
                        }
                        
                        // Gelir Ayarları
                        SettingsSection(title: "Gelir" ) {
                            // Aylık Gelir
                            SettingsNavigationRow(
                                title: "Aylık Gelir",
                                icon: "banknote.fill",
                                iconColor: .green,
                                value: String(format: "%.2f %@", monthlyIncome, selectedCurrency.symbol)
                            ) {
                                IncomeEditView(income: $monthlyIncome, currency: selectedCurrency)
                            }
                        }
                        
                        // Güvenlik Ayarları
                        SettingsSection(title: "Güvenlik") {
                            // Biyometrik Kimlik Doğrulama
                            SettingsToggleRow(
                                title: "Face ID / Touch ID (fake)",
                                icon: "faceid",
                                iconColor: .blue,
                                isOn: $isBiometricEnabled
                            )
                            
                            // PIN Kodu
                            SettingsToggleRow(
                                title: "PIN Kodu (fake)",
                                icon: "lock.fill",
                                iconColor: .red,
                                isOn: $isPINEnabled
                            )
                            
                            // Şifre Değiştir
                            SettingsNavigationRow(
                                title: "Şifre Değiştir (fake)",
                                icon: "key.fill",
                                iconColor: .yellow
                            ) {
                                // Şifre Değiştirme Ekranı
                            }
                        }
                        
                        // Veri Yönetimi
                        SettingsSection(title: "Veri Yönetimi") {
                            // Yedekleme & Geri Yükleme
                            SettingsNavigationRow(
                                title: "Yedekleme & Geri Yükleme (fake) ",
                                icon: "arrow.clockwise",
                                iconColor: .green
                            ) {
                                // Yedekleme Ekranı
                            }
                        }
                        
                        // Uygulama Hakkında
                        SettingsSection(title: "Uygulama Hakkında") {
                            // Sürüm Bilgisi
                            SettingsInfoRow(
                                title: "Uygulama Sürümü",
                                icon: "info.circle.fill",
                                iconColor: .blue,
                                value: "1.0.0"
                            )
                            
                            // Gizlilik Politikası
                            SettingsNavigationRow(
                                title: "Gizlilik Politikası (fake)",
                                icon: "hand.raised.fill",
                                iconColor: .gray
                            ) {
                                // Gizlilik Politikası Ekranı
                            }
                            
                            // Kullanım Koşulları
                            SettingsNavigationRow(
                                title: "Kullanım Koşulları (fake)",
                                icon: "doc.text.fill",
                                iconColor: .gray
                            ) {
                                // Kullanım Koşulları Ekranı
                            }
                            
                            // Destek
                            SettingsNavigationRow(
                                title: "Destek (fake)",
                                icon: "questionmark.circle.fill",
                                iconColor: AppColors.primaryBlue
                            ) {
                                // Yardım ve Destek Ekranı
                            }
                        }
                        
                        // Çıkış Yap
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            HStack {
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Çıkış Yap")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(AppColors.expense)
                                
                                Spacer()
                            }
                            .padding()
                            .background(AppColors.cardDark)
                            .cornerRadius(12)
                        }
                        
                     /*   Text("Finansor © 2025")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextDark)
                            .padding(.top, 8)
                            .padding(.bottom, 30)*/
                    }
                    .padding()
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Çıkış Yap"),
                    message: Text("Uygulamadan çıkış yapmak istediğinize emin misiniz?"),
                    primaryButton: .destructive(Text("Çıkış Yap")) {
                        showWelcomeView.toggle()
                    },
                    secondaryButton: .cancel(Text("İptal"))
                )
            }
            .fullScreenCover(isPresented: $showWelcomeView, content: {
                WelcomeView()
            })
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textDark)
                .padding(.leading)
            
            VStack(spacing: 0) {
                content
            }
            .background(AppColors.cardDark)
            .cornerRadius(12)
        }
    }
}

struct SettingsToggleRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 20))
                .frame(width: 30, height: 30)
            
            Text(title)
                .foregroundColor(AppColors.textDark)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColors.primaryBlue)
        }
        .padding()
        .background(AppColors.cardDark)
        
        Divider()
            .background(Color.gray.opacity(0.2))
            .padding(.leading, 60)
    }
}

struct SettingsNavigationRow<Destination: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    var value: String? = nil
    let destination: Destination
    
    init(title: String, icon: String, iconColor: Color, value: String? = nil, @ViewBuilder destination: @escaping () -> Destination) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.value = value
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20))
                    .frame(width: 30, height: 30)
                
                Text(title)
                    .foregroundColor(AppColors.textDark)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .foregroundColor(AppColors.secondaryTextDark)
                        .font(.subheadline)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryTextDark)
            }
            .padding()
            .background(AppColors.cardDark)
        }
        .buttonStyle(PlainButtonStyle())
        
        Divider()
            .background(Color.gray.opacity(0.2))
            .padding(.leading, 60)
    }
}

struct SettingsInfoRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 20))
                .frame(width: 30, height: 30)
            
            Text(title)
                .foregroundColor(AppColors.textDark)
            
            Spacer()
            
            Text(value)
                .foregroundColor(AppColors.secondaryTextDark)
                .font(.subheadline)
        }
        .padding()
        .background(AppColors.cardDark)
        
        Divider()
            .background(Color.gray.opacity(0.2))
            .padding(.leading, 60)
    }
}

enum Currency: String {
    case usd = "USD ($)"
    case eur = "EUR (€)"
    case gbp = "GBP (£)"
    case `try` = "TRY (₺)"
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .try: return "₺"
        }
    }
}

enum Language: String {
    case english = "English"
    case turkish = "Türkçe"
}

// Gelir Düzenleme Ekranı
struct IncomeEditView: View {
    @Binding var income: Double
    let currency: Currency
    @State private var incomeText: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Aylık Gelirinizi Düzenleyin")
                .font(.headline)
                .padding(.top)
            
            HStack {
                Text(currency.symbol)
                    .font(.title2)
                    .foregroundColor(AppColors.textDark)
                
                TextField("Aylık Gelir", text: $incomeText)
                    .keyboardType(.decimalPad)
                    .font(.title2)
                    .padding()
                    .background(AppColors.backgroundDark.opacity(0.3))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Button(action: {
                if let newIncome = Double(incomeText) {
                    income = newIncome
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Kaydet")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.primaryBlue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(AppColors.backgroundDark)
        .navigationTitle("Gelir Düzenle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            incomeText = "\(income)"
        }
    }
}

#Preview {
    SettingsTabView()
}
