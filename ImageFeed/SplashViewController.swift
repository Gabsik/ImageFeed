
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private var isProfileLoaded = false
    
    private let splashScreenLogoImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting()
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            
            let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
            guard let authViewController = viewController else { return }
            authViewController.delegate = self
            
            authViewController.modalPresentationStyle = .fullScreen
            self.present(authViewController, animated: true)
        }
    }
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //
    //        if let token =  oauth2TokenStorage.token {
    //            fetchProfile(token)
    //        } else {
    //            let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //            guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
    //                assertionFailure("Unable to instantiate AuthViewController")
    //                return
    //            }
    //            authViewController.delegate = self
    //            authViewController.modalPresentationStyle = .fullScreen
    //            present(authViewController, animated: true)
    //        }
    //    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        //        switchToTabBarController()
        
        guard let token = oauth2TokenStorage.token else {
            return
        }
        fetchProfile(token: token)
    }
    
    private func fetchProfile(token: String) {
        ProgressHUD.show()
        
        profileService.fetchProfile(token) { [ weak self ] result in
            ProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                print("Профиль получен: \(profile)")
                guard let username = profile.username else { return }
                ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
                    
                    switch result {
                    case.success(let smalImage):
                        print(smalImage)
                    case.failure(let error):
                        print("[SplashViewController] - \(error.localizedDescription)")
                    }
                }
                self.switchToTabBarController()
            case.failure:
                print("[SplashViewController] - ошибка загрузка профиля")
                break
            }
        }
    }
}

extension SplashViewController {
    private func setting() {
        splashScreenLogoImageView.image = UIImage(named: "splash_screen_logo")
        splashScreenLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        splashScreenLogoImageView.contentMode = .scaleToFill
        
        view.addSubview(splashScreenLogoImageView)
        
        NSLayoutConstraint.activate([
            splashScreenLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
