
import Foundation

final class OAuth2TokenStorage {
    private let key = "OAuth2Token"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: key)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
}
