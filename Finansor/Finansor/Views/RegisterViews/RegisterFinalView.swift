import SwiftUI
import Combine

enum PasswordStrength {
    case weak
    case medium
    case strong
}
class KeyboardResponder: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { _ in self.isKeyboardVisible = true }
            .store(in: &cancellableSet)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in self.isKeyboardVisible = false }
            .store(in: &cancellableSet)
    }
}

struct RegisterFinalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showCompletionSheet: Bool = false
    @State private var showLoginView: Bool = false
    @StateObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        ZStack {
            FinansorColors.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Üst kısım - Geri butonu
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 20)
                
                // Başlık kısmı
                VStack(spacing: 12) {
                    Text("Kayıt İşlemini Tamamla")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    
                    Text("Hesabınızı oluşturmak için parola belirleyin")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                }
                
                // Form alanları
                VStack(spacing: 20) {
                    // E-posta (readonly)
                    TextField("", text: .constant(userViewModel.tempEmail))
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                        .textFieldStyle(FinansorTextFieldStyle())
                        .disabled(true)
                        .frame(height: 50)
                        .background(
                            ZStack {
                                // Gölge
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.2))
                                    .offset(y: 2)
                                
                                // Arkaplan
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.1))
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    
                    // Parola
                    ZStack(alignment: .trailing) {
                        if showPassword {
                            TextField("Parola", text: $password)
                                .font(.title3)
                                .foregroundColor(.white)
                                .textFieldStyle(FinansorTextFieldStyle())
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
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                        } else {
                            SecureField("Parola", text: $password)
                                .font(.title3)
                                .foregroundColor(.white)
                                .textFieldStyle(FinansorTextFieldStyle())
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
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.trailing, 30)
                    }
                    
                    // Confirm Password
                    ZStack(alignment: .trailing) {
                        if showPassword {
                            TextField("Parolayı Tekrarla", text: $confirmPassword)
                                .font(.title3)
                                .foregroundColor(.white)
                                .textFieldStyle(FinansorTextFieldStyle())
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
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                        } else {
                            SecureField("Parolayı Tekrarla", text: $confirmPassword)
                                .font(.title3)
                                .foregroundColor(.white)
                                .textFieldStyle(FinansorTextFieldStyle())
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
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                        }
                    }
                }
                
                // Şifre gücü göstergesi
                VStack(alignment: .leading, spacing: 8) {
                    Text("Parola Gücü")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.leading, 20)
                    
                    HStack(spacing: 2) {
                        Rectangle()
                            .fill(passwordStrength == .weak ? Color.red : Color.red.opacity(0.3))
                            .frame(height: 6)
                        
                        Rectangle()
                            .fill(passwordStrength == .medium || passwordStrength == .strong ? Color.yellow : Color.gray.opacity(0.3))
                            .frame(height: 6)
                        
                        Rectangle()
                            .fill(passwordStrength == .strong ? Color.green : Color.gray.opacity(0.3))
                            .frame(height: 6)
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 5)
                    
                    Text(passwordStrengthText)
                        .foregroundColor(passwordStrengthColor)
                        .font(.subheadline)
                        .padding(.leading, 20)
                        
                    if !passwordsMatch && !confirmPassword.isEmpty {
                        Text("Parolalar eşleşmiyor")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.leading, 20)
                    }
                }
                
                Spacer()
                
                // Zaten hesabın var mı?
                if !keyboard.isKeyboardVisible {
                    HStack {
                        Text("Zaten bir hesabın var mı?")
                            .foregroundColor(.white)
                        
                        Button("Giriş Yap") {
                            showLoginView = true
                        }
                        .foregroundColor(FinansorColors.accentYellow)
                    }
                    .padding(.bottom, 20)
                    .fullScreenCover(isPresented: $showLoginView, content: {
                        LoginView()
                            .environmentObject(userViewModel)
                    })
                }
                // Kayıt ol butonu
                Button(action: {
                    registerUser()
                    hideKeyboard()
                }) {
                    ZStack {
                        Circle()
                            .fill(isFormValid ? FinansorColors.accentYellow : Color.gray.opacity(0.3))
                            .frame(width: 70, height: 70)
                        
                        if userViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(1.5)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(FinansorColors.BackwardCompatibility.backgroundDarkBlue)
                        }
                    }
                }
                .disabled(!isFormValid || userViewModel.isLoading)
                .padding(.bottom, 80)
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("Tamam", role: .cancel) {}
        }
        .sheet(isPresented: $showCompletionSheet) {
            FinalCompletionSheetView()
                .environmentObject(userViewModel)
                .presentationDetents([.fraction(0.5)])
        }
   
    }
    
    private var passwordStrength: PasswordStrength {
        if password.isEmpty {
            return .weak
        }
        
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecialChar = password.rangeOfCharacter(from: .punctuationCharacters) != nil
        let length = password.count
        
        if length >= 8 && hasUppercase && hasLowercase && hasDigit && hasSpecialChar {
            return .strong
        } else if length >= 6 && (hasUppercase || hasLowercase) && (hasDigit || hasSpecialChar) {
            return .medium
        } else {
            return .weak
        }
    }
    
    private var passwordStrengthText: String {
        switch passwordStrength {
        case .weak:
            return "Zayıf"
        case .medium:
            return "Orta"
        case .strong:
            return "Güçlü"
        }
    }
    
    private var passwordStrengthColor: Color {
        switch passwordStrength {
        case .weak:
            return .red
        case .medium:
            return .yellow
        case .strong:
            return .green
        }
    }
    
    private var passwordsMatch: Bool {
        return password == confirmPassword
    }
    
    private var isFormValid: Bool {
        !password.isEmpty &&
        password.count >= 6 &&
        !confirmPassword.isEmpty &&
        passwordsMatch
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func registerUser() {
        if !isFormValid {
            if !passwordsMatch {
                alertMessage = "Girdiğiniz parolalar eşleşmiyor."
            } else if password.count < 6 {
                alertMessage = "Parola en az 6 karakter uzunluğunda olmalıdır."
            } else {
                alertMessage = "Lütfen tüm alanları doğru şekilde doldurun."
            }
            showingAlert = true
            return
        }
        
        // Use userViewModel to register the user
        userViewModel.register(
            name: "Kullanıcı", // This would be from previous steps
            email: userViewModel.tempEmail,
            password: password
        ) { success, error in
            if success {
                showCompletionSheet = true
            } else {
                alertMessage = error ?? "Kayıt işlemi sırasında bir hata oluştu."
                showingAlert = true
            }
        }
    }
}

struct FinalCompletionSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var showMainTabView = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 50)
                .foregroundColor(FinansorColors.accentYellow)
            
            Text("Kayıt Tamamlandı!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Hesabınız başarıyla oluşturuldu.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .foregroundColor(.white)
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    showMainTabView.toggle()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(FinansorColors.primaryBlue)
                            .frame(height: 50)
                            .padding(.horizontal,50)
                        
                        Text("Hadi Başlayalım!")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .fullScreenCover(isPresented: $showMainTabView, content: {
                    MainTabView()
                        .environmentObject(userViewModel)
                })
            }
        }
        .background(FinansorColors.backgroundDark)
    }
}

#Preview {
    RegisterFinalView()
        .environmentObject(UserViewModel())
}
