
import Foundation
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) 
        
        let profileViewController = ProfileViewController()
        let presenter = ProfilePresenter()
                profileViewController.presenter = presenter
                presenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        profileViewController.tabBarItem.accessibilityIdentifier = "ProfileTab"
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
