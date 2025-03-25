
import UIKit

final class AuthViewController: UIViewController {
    
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let authService = OAuth2Service()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        
    }
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black (iOS)")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webViewVC = segue.destination as? WebViewViewController {
            webViewVC.delegate = self
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        authService.fetchOAuthToken(code) { result in
            switch result {
            case .success(let token):
                print("Токен успешно получен: \(token)")
            case .failure(let error):
                print("Ошибка получения токена: \(error)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
