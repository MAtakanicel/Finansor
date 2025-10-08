import SwiftUI

struct RegisterIncomeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 5
    @State private var income: String = ""
    @State private var showRegisterOptions: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var moneyUnit: String = "₺"
    @State private var isFocused: Bool = false

    
    // Dönüştürülmüş değerleri hesapla
    var convertedMoney: Double {
        guard let moneyValue = Double(income) else { return 0 }
        return moneyUnit == "lb" ? moneyValue / 2.20462 : moneyValue
    }
    
    var body: some View {
        ZStack {
            FinansorColors.BackwardCompatibility.backgroundDarkBlue.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Geri butonu ve adım göstergesi
                HStack {
                    Button(action: {
                        currentStep -= 1
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Adım göstergesi
                    StepIndicatorView(currentStep: currentStep)
                    
                    Spacer()
                    
                    // Sağ tarafta boşluk bırakıyoruz (simetri için)
                    Image(systemName: "chevron.left")
                        .foregroundColor(.clear)
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                // Başlık
                Text("Geliriniz.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                

          
                    Text("Lütfen aylık net gelirinizi giriniz.")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 10)
                        .transition(.opacity)
                
                
                Spacer()
                Spacer()
                Spacer()
                // gelir girişi
                VStack(spacing: 20) {
                    // gelir girişi
                    HStack {
                        TextField("Geliriniz", text: $income)
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .multilineTextAlignment(.center)
                            .frame(width: 150)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                        
                        // Boy birimi seçimi
                        Menu {
                            Button("€") {
                                moneyUnit = "€"
                            }
                            Button("₺") {
                                moneyUnit = "₺"
                            }
                            Button("$"){
                                moneyUnit = "$"
                            }
                        } label: {
                            Text(moneyUnit)
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .frame(width: 50, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                )
                        }
                    }
                    Spacer()
    
                }
                
                Spacer()
                
                // Devam butonu
                Button(action: {
                    
                    if income.isEmpty {
                        alertMessage = "Lütfen Gelirinizi Giriniz."
                        showAlert = true
                        return
                    }/*else if Int(income)! < 5000 {
                        
                    }*/
                    
                    let final = convertedMoney
                    showRegisterOptions.toggle()
                    
                }) {
                    ZStack {
                        Circle()
                            .fill(!income.isEmpty ? AppColors.accentYellow : Color.gray.opacity(0.5))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "arrow.right")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .disabled(income.isEmpty)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showRegisterOptions, content: {
            RegisterOptionsMenu()
                .presentationDetents([.fraction(0.35)])
        })

        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Hata"),
                message: Text(alertMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
}


struct RegisterOptionsMenu: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showLoginScreen = false
    @State private var showFinalScreen = false
    
    var body: some View {
        ZStack {
            FinansorColors.BackwardCompatibility.backgroundDarkBlue.ignoresSafeArea()
            
            VStack(spacing: 15) {
                Text("Kaydını tamamla")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                    .padding(.bottom,10)
                
                Button(action: {
                    showFinalScreen.toggle()
                }) {
                    Text("E-posta Kullan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.accentYellow)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .fullScreenCover(isPresented: $showFinalScreen, content: {
                    RegisterFinalView()
                })
                
                Text("veya")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
                
                Button(action: {
                    // Apple ile devam et
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.title2)
                        Text("Apple ile devam et")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                
                HStack(spacing:10){
                    Text("Zaten bir hesabınız var mı ?")
                        
                    Button(action: {
                        showLoginScreen = true
                    }){
                        Text("Giriş Yap")
                            .foregroundColor(AppColors.accentYellow)
                            
                    }
                    .fullScreenCover(isPresented: $showLoginScreen, content:{
                        LoginView()
                    
                    } )
                }
            }
        }
    }
}


#Preview {
    RegisterIncomeView()
}
