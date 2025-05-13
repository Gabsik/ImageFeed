

import XCTest
@testable import ImageFeed

class ProfilePresenterTests: XCTestCase {
    
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

        final class MockProfileService: ProfileServiceProtocol {
            var profile: Profile? = Profile(
                username: "test_username",
                name: "Test User",
                loginName: "@test_username",
                bio: "Test bio"
            )

            var clearDataCalled = false

            func clearData() {
                clearDataCalled = true
            }
        }

        final class MockProfileImageService: ProfileImageServiceProtocol {
            var avatarURL: String? = "https://example.com/avatar.jpg"
        }

        final class MockImagesListService: ImagesListServiceProtocol {
            var clearDataCalled = false

            func clearData() {
                clearDataCalled = true
            }
        }

        // MARK: - Tests

        func testViewDidLoad_ShouldUpdateViewWithProfileAndAvatar() {
            let view = MockProfileViewController()
            let profileService = MockProfileService()
            let imageService = MockProfileImageService()
            let imagesListService = MockImagesListService()

            let presenter = ProfilePresenter(
                profileService: profileService,
                profileImageService: imageService,
                imagesListService: imagesListService
            )

            presenter.view = view

            presenter.viewDidLoad()

            XCTAssertTrue(view.profileDetailsUpdated)
            XCTAssertEqual(view.lastName, "Test User")
            XCTAssertEqual(view.lastLogin, "@test_username")
            XCTAssertEqual(view.lastBio, "Test bio")

            XCTAssertTrue(view.avatarUpdated)
            XCTAssertEqual(view.lastAvatarURL?.absoluteString, "https://example.com/avatar.jpg")
        }

        func testLogoutButtonPressed_ShouldClearAllAndShowAlert() {
            let view = MockProfileViewController()
            let profileService = MockProfileService()
            let imageService = MockProfileImageService()
            let imagesListService = MockImagesListService()

            let presenter = ProfilePresenter(
                profileService: profileService,
                profileImageService: imageService,
                imagesListService: imagesListService
            )

            presenter.view = view

            presenter.logoutButtonPressed()

            XCTAssertTrue(profileService.clearDataCalled)
            XCTAssertTrue(imagesListService.clearDataCalled)
            XCTAssertTrue(view.logoutAlertShown)
        }
}
