import SwiftUI



struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showMainView: Bool = false
    @State private var showRegisterView: Bool = false
    @State private var showForgotPasswordView: Bool = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) var dismiss
    
    
    // Admin girişi için sabit değerler (daha sonra kaldırılacak)
    private let adminEmail = "admin@fitlife.com"
    private let adminPassword = "admin123"
    
    var body: some View {
        
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
    
                VStack(spacing: 25) {
                    Image("ScreenLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:200, height: 200)
                            .foregroundColor(.blue)
                    
                    Text("Finansor")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        
                    
                    VStack(spacing: 15) {
                        TextField("E-posta", text: $email)
                            .foregroundColor(.white)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.bottom, 5)
                            .frame(height: 50)
                            .background(
                                ZStack {
                                    // Gölge
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.2))
                                        .offset(y: 2)
                                    
                                    // Arkaplan
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.15))
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        SecureField("Şifre", text: $password)
                            .foregroundColor(.white)
                            .textFieldStyle(CustomTextFieldStyle())
                            .padding(.bottom, 5)
                            .frame(height: 50)
                            .background(
                                ZStack {
                                    // Gölge
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.2))
                                        .offset(y: 2)
                                    
                                    // Arkaplan
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.15))
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        login()
                        
                    }) {
                        Text("Giriş Yap")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primaryBlue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .fullScreenCover(isPresented: $showMainView){
                        MainTabView()
                    }
                
                    
                    HStack(spacing:5){
                        Text("Hesabın yok mu ?")
                            .foregroundColor(.white.opacity(0.9))
                       
                        Button(action: {
                            showRegisterView.toggle()
                        }) {
                            Text("Kayıt ol")
                                .foregroundColor(AppColors.primaryBlue)
                        }
                        
                    }.padding(.top,15)
                    Spacer()
                    
                    HStack{
                        Button(action:{ showForgotPasswordView.toggle() }){
                            Text("Şifreninizi mi unuttunuz ?")
                                .foregroundColor(AppColors.buttonLightBlue)
                        }
                        .sheet(isPresented: $showForgotPasswordView){
                            ForgetPasswordView().presentationDetents([.fraction(0.2)])
                        }
                    }
                    
                }
                
                .padding()
            }
            .fullScreenCover(isPresented: $showRegisterView) {
                RegisterNameView()
            }
       
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        
    }
    
    private func login() {
        // E-posta ve şifre kontrolü
        guard !email.isEmpty else {
            errorMessage = "Lütfen e-posta adresinizi girin"
            showError = true
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Lütfen şifrenizi girin"
            showError = true
            return
        }
        
            showMainView = true
        
        
        
    }
    

}

#Preview {
    LoginView()
}
