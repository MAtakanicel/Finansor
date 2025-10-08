//
//  LoginView.swift
//  Finansor
//
//  Created by Atakan İçel on 27.03.2025.
//

import SwiftUI

// KeyboardResponder sınıfını burada tanımlayarak çakışmaları önleyelim
class LoginKeyboardResponder: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
    }
}

struct LoginView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showRegisterView = false
    
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    @StateObject private var keyboardResponder = LoginKeyboardResponder()
    
    @State private var isPasswordVisible = false
    @State private var showAlert = false
    @State private var showForgetPasswordView = false
    
    var body: some View {
        ZStack {
            FinansorColors.backgroundDark
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Üstteki görsel ve başlık
                VStack(spacing: 10) {
                    Image("ScreenLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    Text("Finansor'a Hoş Geldiniz")
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    Text("Finansal özgürlüğün bir adım uzağındasın")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Giriş Formu
                VStack(spacing: 20) {
                    // Email TextField
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(isEmailFocused ? .white : .gray)
                            
                            Spacer()
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isEmailFocused ? Color.white : Color.gray.opacity(0.5), lineWidth: 1)
                                .frame(height: 50)
                            
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(isEmailFocused ? .white : .gray)
                                
                                TextField("", text: $email)
                                    .placeholder(when: email.isEmpty) {
                                        Text("E-mail adresinizi girin")
                                            .foregroundColor(.gray.opacity(0.7))
                                    }
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .disableAutocorrection(true)
                                    .focused($isEmailFocused)
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    
                    // Password TextField
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Şifre")
                                .font(.subheadline)
                                .foregroundColor(isPasswordFocused ? .white : .gray)
                            
                            Spacer()
                            
                            Button {
                                showForgetPasswordView = true
                            } label: {
                                Text("Şifremi Unuttum")
                                    .font(.subheadline)
                                    .foregroundColor(FinansorColors.buttonLightBlue)
                            }
                            .sheet(isPresented: $showForgetPasswordView) {
                                ForgetPasswordView()
                                    .environmentObject(userViewModel)
                            }
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isPasswordFocused ? Color.white : Color.gray.opacity(0.5), lineWidth: 1)
                                .frame(height: 50)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(isPasswordFocused ? .white : .gray)
                                
                                if isPasswordVisible {
                                    TextField("", text: $password)
                                        .placeholder(when: password.isEmpty) {
                                            Text("Şifrenizi girin")
                                                .foregroundColor(.gray.opacity(0.7))
                                        }
                                        .foregroundColor(.white)
                                        .disableAutocorrection(true)
                                        .focused($isPasswordFocused)
                                } else {
                                    SecureField("", text: $password)
                                        .placeholder(when: password.isEmpty) {
                                            Text("Şifrenizi girin")
                                                .foregroundColor(.gray.opacity(0.7))
                                        }
                                        .foregroundColor(.white)
                                        .disableAutocorrection(true)
                                        .focused($isPasswordFocused)
                                }
                                
                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    
                    // Login Button
                    Button {
                        login()
                    } label: {
                        Text("Giriş Yap")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(FinansorColors.buttonLightBlue)
                            .cornerRadius(10)
                    }
                    .disabled(userViewModel.isLoading)
                    .opacity(userViewModel.isLoading ? 0.7 : 1)
                    
                    HStack (spacing: 5) {
                        Text("Üye değil misiniz?")
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button(action: {
                            showRegisterView.toggle()
                        }) {
                            Text("Hesap Oluşturun")
                                .foregroundColor(FinansorColors.buttonLightBlue)
                        }
                        .fullScreenCover(isPresented: $showRegisterView, content: {
                            RegisterNameView()
                                .environmentObject(userViewModel)
                        })
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Hata"),
                    message: Text(userViewModel.errorMessage ?? "Bir hata oluştu"),
                    dismissButton: .default(Text("Tamam"))
                )
            }
            .padding(.bottom, keyboardResponder.isKeyboardVisible ? 30 : 0)
            .animation(.default, value: keyboardResponder.isKeyboardVisible)
            
            if userViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onChange(of: userViewModel.errorMessage, perform: { error in
            if error != nil {
                showAlert = true
            }
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func login() {
        userViewModel.isLoading = true
        userViewModel.login(email: email, password: password) { success, error in
            if !success {
                userViewModel.errorMessage = error ?? "Login failed"
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserViewModel())
}
