
import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let authService = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private var isLoading = false
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        //view.backgroundColor = UIColor(named: "YP Black (iOS)")
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black (iOS)")
        
//        let backButton = UIButton(type: .system)
//        let backImage = UIImage(named: "nav_back_button") // Системная стрелка
//        backButton.setImage(backImage, for: .normal)
//        backButton.tintColor = .white // Цвет стрелки
//        backButton.translatesAutoresizingMaskIntoConstraints = false
//        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        view.addSubview(backButton)
//
//        // Констрейнты
//        NSLayoutConstraint.activate([
//            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            backButton.widthAnchor.constraint(equalToConstant: 32),
//            backButton.heightAnchor.constraint(equalToConstant: 32)
//        ])
    }
    
    @objc private func backButtonTapped() {
        //navigationController?.popViewController(animated: true)
          dismiss(animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
            webViewViewController.modalPresentationStyle = .fullScreen
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true)
//        vc.navigationController?.popViewController(animated: true)
        //vc.dismiss(animated: true)
        showLoading()
        
        authService.fetchOAuthToken(code: code) { [weak self] token in
            guard let self = self else { return }
            
            self.hideLoading()
            switch token {
            case .success(let result):
                self.oauth2TokenStorage.token = result
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print("[AuthViewController]: Ошибка авторизации - \(error.localizedDescription)")
                let alert = UIAlertController(title: "Что-то пошло не так", message: "Не удалось войти в систему", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
        //vc.navigationController?.popViewController(animated: true)
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
//    }
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
