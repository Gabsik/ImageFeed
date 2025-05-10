
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let keyToken: String = "Bearer Token"
    
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: keyToken)
        }
        
        set {
            guard let token = newValue else { return }
            KeychainWrapper.standard.set(token, forKey: keyToken)
        }
    }
    func clearStorage() {
        KeychainWrapper.standard.removeObject(forKey: keyToken)
    }
    func isTokenValid() -> Bool {
        if let token = token {
            if token.isEmpty {
                return false
            } else {
                return true
            }
        }
        return false
    }
}
