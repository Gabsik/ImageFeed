import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let key = "authorizationToken"

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: key)
        }
        set {
            // Если newValue == nil, оставляем старый токен (при необходимости можно add remove)
            guard let token = newValue else { return }
            KeychainWrapper.standard.set(token, forKey: key)
        }
    }
}



//import Foundation
//import SwiftKeychainWrapper
//
//final class OAuth2TokenStorage {
//    var token: String? {
//        get {
//            return KeychainWrapper.standard.string(forKey: "authorizationToken")
//        }
//
//        set {
//            guard let token = newValue else { return }
//            KeychainWrapper.standard.set(token, forKey: "authorizationToken")
//        }
//    }
//}
