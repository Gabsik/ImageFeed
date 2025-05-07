import Foundation
import WebKit
import UIKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        clearToken()
        cleanCookies()
        
        let splashViewController = SplashViewController()
        splashViewController.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first?.rootViewController?.present(splashViewController, animated: true, completion: nil)
    }
    
    private func clearToken() {
        OAuth2TokenStorage().token = nil
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    func showLogoutAlert (from viewController: UIViewController) {
        let alert = UIAlertController(title: "Выход из аккаунта", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
        
        let logoutAction = UIAlertAction(title: "Да", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true)
    }
}
