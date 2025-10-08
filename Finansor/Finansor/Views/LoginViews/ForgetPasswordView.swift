import SwiftUI
import Combine

struct ForgetPasswordView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var isSubmitting: Bool = false
    @State private var message: String?
    @State private var showMessage: Bool = false
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Şifre Sıfırlama")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("E-posta adresiniz", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            if showMessage, let message = message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(message.contains("gönderildi") ? .green : FinansorColors.warningRed)
            }
            
            Button(action: {
                resetPassword()
            }) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Şifre Sıfırlama Bağlantısı Gönder")
                        .font(.callout)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(FinansorColors.buttonLightBlue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(email.isEmpty || isSubmitting)
            
            Button("İptal") {
                dismiss()
            }
            .foregroundColor(.white)
            .padding(.top, 10)
        }
        .padding()
        .background(FinansorColors.backgroundDark)
    }
    
    private func resetPassword() {
        isSubmitting = true
        userViewModel.resetPassword(email: email)
            .receive(on: DispatchQueue.main)
            .sink { success in
                isSubmitting = false
                showMessage = true
                if success {
                    message = "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi."
                } else {
                    message = "Şifre sıfırlama işlemi başarısız oldu. Lütfen tekrar deneyin."
                }
            }
            .store(in: &cancellables)
    }
}

#Preview {
    ForgetPasswordView()
        .environmentObject(UserViewModel())
}
