
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let imageViewProfile = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    private let tokenStorage = OAuth2TokenStorage()
    private var profileService = ProfileService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("didChangeNotification received, updating avatar")
            guard let self = self else { return }
            self.updateAvatar()
        }
        
        addSubviewWithConstraints()
        setupImageView()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
        
        //        guard let authToken = tokenStorage.token else {
        //            print("No authorization token found.")
        //            return
        //        }
        
        if let profile = ProfileService.shared.profile {
                    updateProfileDetails(profile: profile)
                }
        
//        profileImageServiceObserver = NotificationCenter.default.addObserver(
//            forName: ProfileImageService.didChangeNotification,
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            print("didChangeNotification received, updating avatar")
//            guard let self = self else { return }
//            self.updateAvatar()
//        }
//        updateProfileDetails()
        updateAvatar()
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
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.textColor = UIColor(named: "YP Gray (iOS)")
        
        NSLayoutConstraint.activate([
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupDescriptionLabel() {
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
    }
    
    private func updateProfileDetails(profile: ProfileService.Profile) {
            nameLabel.text = profile.name
            loginNameLabel.text = profile.loginName
            descriptionLabel.text = profile.bio
        }
//    func updateProfileDetails() {
//        guard let profile = profileService.profile else { return }
//
//        nameLabel.text = profile.name
//        loginNameLabel.text = profile.loginName
//        descriptionLabel.text = profile.bio
//    }
    
    private func updateAvatar() {
        
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        imageViewProfile.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [.transition(.fade(0.2))]
        )
        //        guard let profileImageURL = ProfileImageService.shared.avatarURL else { return }
        //
        //        if let profileImageURL = URL(string: profileImageURL) {
        //            let profileImageView = profileImageView
        //            print("Loading avatar from URL:", profileImageURL)
        //            profileImageView.kf.setImage(
        //                with: profileImageURL,
        //                placeholder: UIImage(named: "placeholder"),
        //                options: [.forceRefresh]
        //            )
        //
        //        }
    }
}

