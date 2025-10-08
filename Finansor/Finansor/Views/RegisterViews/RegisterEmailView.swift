import SwiftUI

struct RegisterEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var email = ""
    @State private var showNextView = false
    @State private var currentStep = 4
    @State private var emailError: String? = nil
    
    var body: some View {
        ZStack {
            FinansorColors.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with back button and step indicator
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Step indicator
                    StepIndicatorView(currentStep: currentStep)
                    
                    Spacer()
                    
                    // Empty space for symmetry
                    Image(systemName: "chevron.left")
                        .foregroundColor(.clear)
                }
                .padding(.horizontal)
                .padding(.top, 30)
                
                // Content
                VStack(alignment: .center, spacing: 15) {
                    Text("E-posta")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Hesabınızı oluşturmak için e-posta adresinizi girin")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))
                        .padding(.bottom, 10)
                    
                    // Email input
                    TextField("", text: $email)
                        .finansorStyle()
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal)
                        .onChange(of: email) { _ in
                            // Clear error when user types
                            emailError = nil
                        }
                    
                    // Error message
                    if let error = emailError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(FinansorColors.warningRed)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            
            // Continue button
            VStack {
                Spacer()
                
                Button(action: {
                    validateAndContinue()
                }) {
                    ZStack {
                        Circle()
                            .fill(email.isEmpty ? Color.gray.opacity(0.5) : FinansorColors.accentYellow)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(email.isEmpty)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .fullScreenCover(isPresented: $showNextView) {
            RegisterFinalView()
                .environmentObject(userViewModel)
        }
        .animation(.easeInOut, value: emailError)
    }
    
    // Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func validateAndContinue() {
        if email.isEmpty {
            emailError = "E-posta adresi boş bırakılamaz."
            return
        }
        
        if !isValidEmail(email) {
            emailError = "Geçerli bir e-posta adresi giriniz."
            return
        }
        
        // Store email in view model before continuing
        userViewModel.tempEmail = email
        showNextView = true
    }
}

#Preview {
    RegisterEmailView()
        .environmentObject(UserViewModel())
} 