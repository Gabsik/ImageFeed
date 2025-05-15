@testable import ImageFeed
import XCTest

final class ProfileViewPresenterTests: XCTestCase {
    
    final class MockProfileViewController: ProfileViewControllerProtocol {
        var presenter: ProfilePresenterProtocol?
        
        var avatarUpdated = false
        var lastAvatarURL: URL?
        var placeholderImage: UIImage?
        
        var profileDetailsUpdated = false
        var lastName: String?
        var lastLogin: String?
        var lastBio: String?
        
        var logoutAlertShown = false
        
        func updateAvatar(url: URL?, placeholder: UIImage?) {
            avatarUpdated = true
            lastAvatarURL = url
            placeholderImage = placeholder
        }
        
        func updateProfileDetails(name: String?, loginName: String?, bio: String?) {
            profileDetailsUpdated = true
            lastName = name
            lastLogin = loginName
            lastBio = bio
        }
        
        func showLogoutAlert() {
            logoutAlertShown = true
        }
    }
    
    final class MockProfileService: ProfileService {
        override var profile: Profile? {
            return Profile(
                id: "123",
                name: "Test User",
                username: "test_username",
                bio: "Test bio"
            )
        }
    }
    
    final class MockProfileImageService: ProfileImageService {
        override var avatarURL: String? {
            return "https://example.com/avatar.jpg"
        }
    }
    
    func testViewDidLoad_WithProfileAndAvatar_ShouldUpdateUI() {
        // Arrange
        let view = MockProfileViewController()
        let presenter = ProfilePresenter()
        presenter.view = view
        
        ProfileService.shared = MockProfileService()
        ProfileImageService.shared = MockProfileImageService()
        
        // Act
        presenter.viewDidLoad()
        
        // Assert
        XCTAssertTrue(view.profileDetailsUpdated, "Profile details should be updated")
        XCTAssertEqual(view.lastName, "Test User")
        XCTAssertEqual(view.lastLogin, "test_username")
        XCTAssertEqual(view.lastBio, "Test bio")
        
        XCTAssertTrue(view.avatarUpdated, "Avatar should be updated")
        XCTAssertEqual(view.lastAvatarURL?.absoluteString, "https://example.com/avatar.jpg")
    }
    
    func testLogoutButtonPressed_ShouldClearDataAndShowAlert() {
        // Arrange
        let view = MockProfileViewController()
        let presenter = ProfilePresenter()
        presenter.view = view
        
        // Act
        presenter.logoutButtonPressed()
        
        // Assert
        XCTAssertTrue(view.logoutAlertShown, "Logout alert should be shown")
    }
}
