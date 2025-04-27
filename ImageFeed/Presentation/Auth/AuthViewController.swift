
import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let authService = OAuth2Service.shared
    private var isLoading = false
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
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
        
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.showLoading()
            self.fetchOAuthToken(code)
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

extension AuthViewController {
    private func fetchOAuthToken(_ code: String) {
        authService.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            
            self.hideLoading()
            
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print("[AuthViewController]: Ошибка авторизации - \(error.localizedDescription)")
                self.showLoginErrorAlert()
            }
        }
    }
}

extension AuthViewController {
    private func showLoginErrorAlert() {
        print("[AuthViewController]: Показываем алерт об ошибке входа")
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension AuthViewController {
    private func showLoading() {
        isLoading = true
        ProgressHUD.show()
    }
    
    private func hideLoading() {
        isLoading = false
        ProgressHUD.dismiss()
    }
}
