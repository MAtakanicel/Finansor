import Foundation
import SwiftUI
import Combine

/// Veri saklama işlemlerini yönetmek için servis
class DataStorageService {
    static let shared = DataStorageService()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Public Methods
    
    // Nesneyi UserDefaults'a kaydet
    func save<T: Encodable>(_ object: T, forKey key: StorageKey) {
        do {
            let data = try JSONEncoder().encode(object)
            userDefaults.set(data, forKey: key.rawValue)
            
            // Değişiklik bildirimini yayınla
            NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
        } catch {
            print("Failed to save data for key \(key.rawValue): \(error.localizedDescription)")
        }
    }
    
    // UserDefaults'tan nesneyi oku
    func load<T: Decodable>(forKey key: StorageKey) -> T? {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            return nil
        }
        
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            print("Failed to load data for key \(key.rawValue): \(error.localizedDescription)")
            return nil
        }
    }
    
    // UserDefaults'tan nesneyi sil
    func remove(forKey key: StorageKey) {
        userDefaults.removeObject(forKey: key.rawValue)
        
        // Değişiklik bildirimini yayınla
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
    }
    
    // Tüm verileri temizle
    func clearAll() {
        for key in StorageKey.allCases {
            userDefaults.removeObject(forKey: key.rawValue)
        }
        
        // Değişiklik bildirimini yayınla
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
    }
    
    // Check if data exists for key
    func exists(forKey key: StorageKey) -> Bool {
        return userDefaults.object(forKey: key.rawValue) != nil
    }
}

/// Saklama anahtarlarını tanımlayan enum
enum StorageKey: String, CaseIterable {
    case transactions = "finansor_transactions"
    case categories = "finansor_categories"
    case budgets = "finansor_budgets"
    case user = "finansor_user"
    case settings = "finansor_settings"
    case userProfile = "finansor_user_profile"  
    case userSettings = "finansor_user_settings"
    case reminders = "finansor_reminders"
}

// MARK: - Publisher Extensions

extension DataStorageService {
    // UserDefaults'ta değişiklik olduğunda bildirim yapacak bir Publisher oluştur
    func publisher<T: Decodable>(forKey key: StorageKey) -> AnyPublisher<T?, Never> {
        return NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { [weak self] _ in
                guard let self = self else { return nil }
                return self.load(forKey: key)
            }
            .replaceNil(with: nil)
            .eraseToAnyPublisher()
    }
}

// MARK: - SwiftUI Color Codable Extensions

// Color sınıfına Codable uyumluluğu ekle
extension Color: Codable {
    private struct Components {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
    }
    
    private enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        let a = try container.decode(Double.self, forKey: .alpha)
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // UIColor'a dönüştürerek bileşenleri al
        #if os(iOS)
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #elseif os(macOS)
        let nsColor = NSColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        
        try container.encode(Double(r), forKey: .red)
        try container.encode(Double(g), forKey: .green)
        try container.encode(Double(b), forKey: .blue)
        try container.encode(Double(a), forKey: .alpha)
    }
} 