import SwiftUI

struct RegisterNameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var name = ""
    @State private var showRegisterBirthdayView = false
    @State private var currentStep = 1
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var isNameFieldFocused: Bool
    @State private var showWelcomeView : Bool = false
    
    var body: some View {
        ZStack {
            FinansorColors.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Üst kısım - Geri butonu ve adım göstergesi
                HStack {
                    Button(action: {
                        showWelcomeView.toggle()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    .fullScreenCover(isPresented: $showWelcomeView, content: {
                        WelcomeView()
                            .environmentObject(userViewModel)
                    })
                    
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
                
                // İçerik
                VStack(alignment: .center, spacing: 15) {
                    Text("İsim")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Merhaba, deneyiminizi size özel hale getirmek için isminizi istiyoruz")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))
                        .padding(.bottom, 10)
                    
                    // İsim girişi
                    TextField("", text: $name)
                        .finansorStyle()
                        .focused($isNameFieldFocused)
                        .keyboardType(.default)
                        .textContentType(.name)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .padding(.horizontal)
                    
                    // Gizlilik bilgileri
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Gizlilik")
                            .font(.system(size: 15,weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("İsminiz ve kişisel bilgileriniz kimseyle paylaşılmaz")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                }
                .padding(.top,20)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            
            // Devam butonu - her zaman ekranın ortasında
            VStack {
                Spacer()
                
                Button(action: {
                    if currentStep < 5 {
                        currentStep += 1
                        showRegisterBirthdayView = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(!name.isEmpty ? FinansorColors.accentYellow : Color.gray.opacity(0.5))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(name.isEmpty)
                .padding(.bottom, isNameFieldFocused ? 20 : 30)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear {
            // Ekran açıldığında TextField'a otomatik focus
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFieldFocused = true
            }
        }
        .fullScreenCover(isPresented: $showRegisterBirthdayView) {
            RegisterBirthdayView()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Hata"),
                message: Text(alertMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
}

#Preview {
    RegisterNameView()
        .environmentObject(UserViewModel())
}
