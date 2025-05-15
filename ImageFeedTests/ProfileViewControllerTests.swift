

import XCTest
@testable import ImageFeed

class ProfileViewControllerTests: XCTestCase {
    
    final class PresenterSpy: ProfilePresenterProtocol {
            weak var view: ProfileViewControllerProtocol?

            private(set) var viewDidLoadCalled = false
            private(set) var updateAvatarCalled = false
            private(set) var logoutButtonPressedCalled = false

            func viewDidLoad() {
                viewDidLoadCalled = true
            }

            func updateAvatar() {
                updateAvatarCalled = true
            }

            func logoutButtonPressed() {
                logoutButtonPressedCalled = true
            }
        }

        func testViewDidLoad_CallsPresenterViewDidLoad() {
            let sut = ProfileViewController()
            let presenter = PresenterSpy()
            sut.presenter = presenter
            presenter.view = sut

            sut.loadViewIfNeeded()

            XCTAssertTrue(presenter.viewDidLoadCalled, "viewDidLoad() должно вызываться у презентера")
        }

        func testDidTapLogoutButton_CallsPresenterLogout() {
            let sut = ProfileViewController()
            let presenter = PresenterSpy()
            sut.presenter = presenter
            presenter.view = sut

            sut.loadViewIfNeeded()
            sut.logoutButton.sendActions(for: .touchUpInside)
            //sut.perform(#selector(ProfileViewController.didTapLogoutButton))
            //sut.perform(Selector(("didTapLogoutButton")))

            XCTAssertTrue(presenter.logoutButtonPressedCalled, "logoutButtonPressed() должно вызываться у презентера")
        }

        func testObserverNotification_CallsPresenterUpdateAvatar() {
            let sut = ProfileViewController()
            let presenter = PresenterSpy()
            sut.presenter = presenter
            presenter.view = sut

            sut.loadViewIfNeeded()

            NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)

            XCTAssertTrue(presenter.updateAvatarCalled, "updateAvatar() должно вызываться у презентера после нотификации")
        }

        func testUpdateProfileDetails_UpdatesUILabels() {
            let sut = ProfileViewController()
            sut.loadViewIfNeeded()

            sut.updateProfileDetails(name: "John Doe", loginName: "@johndoe", bio: "Hello world")

            XCTAssertEqual(sut.nameLabel.text, "John Doe")
            XCTAssertEqual(sut.loginNameLabel.text, "@johndoe")
            XCTAssertEqual(sut.descriptionLabel.text, "Hello world")
        }

        func testUpdateAvatar_WithoutURL_DoesNothing() {
            let sut = ProfileViewController()
            sut.loadViewIfNeeded()

            sut.updateAvatar(url: nil, placeholder: UIImage(named: "placeholder"))

            let initialImage = sut.imageViewProfile.image
            sut.updateAvatar(url: nil, placeholder: UIImage(named: "placeholder"))
            XCTAssertEqual(sut.imageViewProfile.image, initialImage, "Изображение не должно меняться при nil URL")
        }
}
