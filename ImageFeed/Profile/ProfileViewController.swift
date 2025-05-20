
import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateAvatar(url: URL?, placeholder: UIImage?)
    func updateProfileDetails(name: String?, loginName: String?, bio: String?)
    func showLogoutAlert()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    let imageViewProfile = UIImageView()
    let nameLabel = UILabel()
    let loginNameLabel = UILabel()
    let descriptionLabel = UILabel()
    let logoutButton = UIButton()
    
    var presenter: ProfilePresenterProtocol?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        presenter?.viewDidLoad()
        
    }
    
    deinit {
        removeObservers()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
        addSubviewWithConstraints()
        setupImageView()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
    }
    
    func updateAvatar(url: URL?, placeholder: UIImage?) {
        guard let url = url else { return }
        
        imageViewProfile.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2))]
        )
    }
    
    func updateProfileDetails(name: String?, loginName: String?, bio: String?) {
        nameLabel.text = name
        loginNameLabel.text = loginName
        descriptionLabel.text = bio
    }
    
    private func addSubviewWithConstraints() {
        [nameLabel,
         imageViewProfile,
         loginNameLabel,
         descriptionLabel,
         logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupImageView() {
        
        let profilImage = UIImage(named: "avatar")
        imageViewProfile.image = profilImage
        
        NSLayoutConstraint.activate([
            imageViewProfile.widthAnchor.constraint(equalToConstant: 70),
            imageViewProfile.heightAnchor.constraint(equalToConstant: 70),
            imageViewProfile.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            imageViewProfile.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        imageViewProfile.accessibilityIdentifier = "ProfileAvatar"
    }
    
    private func setupNameLabel() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = UIColor(named: "YP White (iOS)")
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageViewProfile.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
    }
    
    private func setupLoginNameLabel() {
        loginNameLabel.accessibilityIdentifier = "userLoginName"
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.textColor = UIColor(named: "YP Gray (iOS)")
        
        NSLayoutConstraint.activate([
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.accessibilityIdentifier = "ProfileDescription"
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = UIColor(named: "YP White (iOS)")
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupLogoutButton() {
        logoutButton.setImage(UIImage(named: "Exit"), for: .normal)
        
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 99),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.accessibilityIdentifier = "LogoutButton"
    }
    
    private func setupObservers() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.updateAvatar()
        }
    }
    
    private func removeObservers() {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func showLogoutAlert() {
        ProfileLogoutService.shared.showLogoutAlert(from: self)
    }
    @objc func didTapLogoutButton() {
        presenter?.logoutButtonPressed()
    }
}

