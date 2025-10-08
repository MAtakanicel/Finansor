import SwiftUI

struct MainWelcomeView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var showLoginView = false
    @State private var showRegisterView = false
    
    var body: some View {
        ZStack {
            // Background
            FinansorColors.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo
                Image(.screenLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundColor(FinansorColors.accentYellow)
                
                // App name and slogan
                VStack(spacing: 12) {
                    Text("Finansor")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Finansal özgürlüğünüz için")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Login button
                Button {
                    showLoginView = true
                } label: {
                    Text("Giriş Yap")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(FinansorColors.buttonLightBlue)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                
                // Register button
                Button {
                    showRegisterView = true
                } label: {
                    Text("Hesap Oluştur")
                        .font(.headline)
                        .foregroundColor(FinansorColors.buttonLightBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(FinansorColors.buttonLightBlue, lineWidth: 2)
                        )
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(.bottom, 50)
        }
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
                .environmentObject(userViewModel)
        }
        .fullScreenCover(isPresented: $showRegisterView) {
            RegisterNameView()
                .environmentObject(userViewModel)
        }
    }
}

#Preview {
    MainWelcomeView()
        .environmentObject(UserViewModel())
} 
