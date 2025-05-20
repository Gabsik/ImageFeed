import Foundation
import UIKit

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar()
    func logoutButtonPressed()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol //ProfileService.shared
    private let profileImageService: ProfileImageServiceProtocol //ProfileImageService.shared
    private let imagesListService: ImagesListServiceProtocol
    private let tokenStorage = OAuth2TokenStorage()
    
    init(
            profileService: ProfileServiceProtocol = ProfileService.shared,
            profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
            imagesListService: ImagesListServiceProtocol = ImagesListService.shared
            //tokenStorage: OAuth2TokenStorage = OAuth2TokenStorage()
        ) {
            self.profileService = profileService
            self.profileImageService = profileImageService
            self.imagesListService = imagesListService
            //self.tokenStorage = tokenStorage
        }
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        updateAvatar()
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        view?.updateAvatar(url: url, placeholder: UIImage(named: "placeholder"))
    }
    
    func logoutButtonPressed() {
        profileService.clearData()
        imagesListService.clearData()
        tokenStorage.clearStorage()
        view?.showLogoutAlert()
    }
    
    private func updateProfileDetails(profile: Profile) {
        view?.updateProfileDetails(
            name: profile.name,
            loginName: profile.loginName,
            bio: profile.bio
        )
    }
}
