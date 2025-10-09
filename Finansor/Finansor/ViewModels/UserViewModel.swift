import SwiftUI
import Combine

class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var tempEmail: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Uygulama başlangıcında kullanıcı oturum durumunu kontrol et
        checkAuthState()
    }
    
    // MARK: - Authentication Methods
    
    // Kullanıcı oturum durumunu kontrol et
    func checkAuthState() {
        // Gerçek uygulamada burada Firebase veya başka bir servis kullanarak
        // kullanıcının oturum durumunu kontrol edebilirsiniz
        // Şimdilik sadece demo kullanıcı yüklüyoruz
        loadDemoUser()
        isAuthenticated = true
    }
    
    // E-posta ve şifre ile giriş
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        
        // Demo için hemen başarılı kabul ediyoruz
        // Gerçek uygulamada burada Firebase Auth veya başka bir servis kullanarak
        // kullanıcı girişi yapılır
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if email.lowercased() == "demo@example.com" && password == "123456" {
                self.loadDemoUser()
                self.isAuthenticated = true
                self.isLoading = false
                completion(true, nil)
            } else {
                self.isLoading = false
                completion(false, "E-posta veya şifre hatalı.")
            }
        }
    }
    
    // Apple ile giriş
    func loginWithApple(completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        
        // Demo için sadece gecikme ile başarılı kabul ediyoruz
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            self.loadDemoUser()
            self.isAuthenticated = true
            self.isLoading = false
            completion(true, nil)
        }
    }
    
    // Kullanıcı kaydı
    func register(name: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        
        // Demo için sadece gecikme ile başarılı kabul ediyoruz
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Demo kullanıcı oluştur
            let newUser = User(
                id: UUID().uuidString,
                name: name,
                email: email,
                photoURL: nil,
                createdAt: Date(),
                lastLoginAt: Date(),
                settings: UserSettings()
            )
            
            self.currentUser = newUser
            self.isAuthenticated = true
            self.isLoading = false
            self.tempEmail = email
            completion(true, nil)
        }
    }
    
    // Çıkış yap
    func logout(completion: @escaping () -> Void) {
        isLoading = true
        
        // Demo için sadece gecikme ile çıkış yapıyoruz
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.currentUser = nil
            self.isAuthenticated = false
            self.isLoading = false
            completion()
        }
    }
    
    // Şifre sıfırlama e-postası gönder
    func resetPassword(email: String) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            // Set loading state
            self.isLoading = true
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Simulated success (in a real app, this would communicate with a server)
                // You could add validation here to check if the email exists in your system
                self.isLoading = false
                
                // Return success if email is not empty
                let success = !email.isEmpty
                promise(.success(success))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - User Profile Methods
    
    // Kullanıcı ayarlarını güncelle
    func updateSettings(_ settings: UserSettings) {
        guard var user = currentUser else { return }
        
        user.settings = settings
        currentUser = user
        
        // Gerçek uygulamada burada Firebase veya başka bir servis ile
        // kullanıcı ayarlarını veritabanına kaydetme işlemi yapılır
    }
    
    // Kullanıcı profilini güncelle
    func updateProfile(name: String, photoURL: String?, completion: @escaping (Bool, String?) -> Void) {
        guard var user = currentUser else {
            completion(false, "Kullanıcı oturumu bulunamadı.")
            return
        }
        
        isLoading = true
        
        // Demo için sadece local kullanıcıyı güncelliyoruz
        user.name = name
        user.photoURL = photoURL
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.currentUser = user
            self.isLoading = false
            completion(true, "Profil başarıyla güncellendi.")
        }
    }
    
    // MARK: - Private Methods
    
    // Demo kullanıcı yükle
    private func loadDemoUser() {
        currentUser = User(
            id: "demo_user_id",
            name: "Demo Kullanıcı",
            email: "demo@example.com",
            photoURL: nil,
            createdAt: Date().addingTimeInterval(-7776000), // 90 gün önce
            lastLoginAt: Date(),
            settings: UserSettings()
        )
    }
} 