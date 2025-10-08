//
//  WelcomeView.swift
//  Finansor
//
//  Created by Atakan İçel on 27.03.2025.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @State private var showLoginOptions = false
    @State private var goRegisterNameView = false
    @State private var showLoginView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Logo ve App ismi
                VStack(spacing: 0) {
                    Image("ScreenLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:200, height: 200)
                        .foregroundColor(.blue)
                    
                    ZStack {
                        // Arka plan katmanları (gri tonlu gölgeler)
                        ForEach(1..<3) { i in
                            Text("Finansor")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.black.opacity(Double(3 - i) * 0.1)) // katman rengi giderek açılıyor
                                .offset(x: CGFloat(2), y: CGFloat(0)) // hafif aşağı ve sağa kaydır
                        }
                        
                        // Ana yazı (ön katman)
                        Text("Finansor")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, -30)
                    }
                }//VStack
               
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action:{ goRegisterNameView.toggle()  }){
                        Text("Yeni bir kullanıcıyım")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(FinansorColors.buttonLightBlue)
                            .cornerRadius(10)
                    }
                    .fullScreenCover(isPresented: $goRegisterNameView, content: { 
                        RegisterNameView()
                            .environmentObject(userViewModel)
                    })
                    .padding(.horizontal, 20)
                    
                    Button(action: { showLoginOptions.toggle() }) {
                        Text("Zaten bir hesabım var")
                            .font(.headline)
                            .foregroundColor(FinansorColors.buttonLightBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(FinansorColors.buttonLightBlue, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 20)
                }//VStack
                
                Spacer()
                
                // Şartlar ve koşullar metni
                HStack(spacing: 0) {
                    Button(action: {}) {
                        Text("Şartlar ve Koşullar")
                            .underline()
                            .foregroundColor(.white)
                    }
                    
                    Text(" ve ")
                        .foregroundColor(.gray)
                    
                    Button(action: {}) {
                        Text("Gizlilik Politikası")
                            .underline()
                            .foregroundColor(.white)
                    }
                    
                    Text("'nı kabul etmiş olursun.")
                        .foregroundColor(.gray)
                }//HStack
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FinansorColors.backgroundDark)
            .edgesIgnoringSafeArea(.all)
        }
        .background(FinansorColors.backgroundDark)
        .sheet(isPresented: $showLoginOptions, content: { 
            LoginOptionsView(showLoginView: $showLoginView)
                .environmentObject(userViewModel)
                .presentationDetents([.fraction(0.35)])
        })
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
                .environmentObject(userViewModel)
        }
    }
}

struct LoginOptionsView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @State private var showRegisterView: Bool = false
    @Binding var showLoginView: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Oturum Aç")
                .frame(maxWidth: .infinity)
                .padding(.top,30)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
            Spacer()
            
            VStack(spacing: 10){
                Button(action: {
                    showLoginView.toggle()
                }) {
                    Text("E-posta ile devam et")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(FinansorColors.buttonLightBlue)
                        .cornerRadius(10)
                }
                
                Text("veya")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.gray)
                
                Button(action: {
                    userViewModel.isLoading = true
                    userViewModel.loginWithApple { success, error in
                        if !success, let error = error {
                            userViewModel.errorMessage = error
                        }
                        dismiss()
                    }
                }){
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.title2)
                        Text("Apple ile Devam Et")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .disabled(userViewModel.isLoading)
            }//VStack
            .padding(20)
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
        }
        .background(FinansorColors.BackwardCompatibility.backgroundLightBlue)
        Spacer()
    }
}

#Preview {
    WelcomeView()
        .environmentObject(UserViewModel())
}
