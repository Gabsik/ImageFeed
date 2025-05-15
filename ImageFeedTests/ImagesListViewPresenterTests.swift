
import XCTest
@testable import ImageFeed


final class ImagesListPresenterTests: XCTestCase {

    // MARK: - Mocks

    final class MockView: ImagesListViewProtocol {
        var didShowError = false
        var errorMessage: String?

        var didSetLikeIcon = false
        var likeIconState: Bool?

        var didShowLoadingIndicator = false
        var didHideLoadingIndicator = false

        func updateTableView() {}

        func insertRows(at indexPaths: [IndexPath]) {}

        func showError(message: String) {
            didShowError = true
            errorMessage = message
        }

        func setLikeIcon(for cell: ImagesListCell, isLiked: Bool) {
            didSetLikeIcon = true
            likeIconState = isLiked
        }

        func showLoadingIndicator() {
            didShowLoadingIndicator = true
        }

        func hideLoadingIndicator() {
            didHideLoadingIndicator = true
        }
    }

    final class MockImageService: ImagesListServiceProtocol {
        var photos: [Photo] = []
        var didCallFetchPhotos = false
        var didCallChangeLike = false
        var changeLikeResult: Result<Void, Error> = .success(())

        func fetchPhotosNextPage(completion: @escaping (Result<Void, Error>) -> Void) {
            didCallFetchPhotos = true
            completion(.success(()))
        }

        func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
            didCallChangeLike = true
            completion(changeLikeResult)
        }

        func clearData() {}
    }

    // MARK: - Tests

    func testViewDidLoadFetchesPhotos() {
        let service = MockImageService()
        let presenter = ImagesListPresenter(imagesService: service, tableViewWidth: 300)
        let view = MockView()
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertTrue(service.didCallFetchPhotos)
    }

    func testGetPhotoItemSizeCalculatesCorrectly() {
        let photo = Photo(id: "1", size: CGSize(width: 200, height: 100), createdAt: nil, description: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        let service = MockImageService()
        service.photos = [photo]

        let presenter = ImagesListPresenter(imagesService: service, tableViewWidth: 320)

        let size = presenter.getPhotoItemSize(at: 0)

        XCTAssertEqual(size.width, 288)
        XCTAssertGreaterThan(size.height, 0)
    }

    func testConfigCellSetsLikeIconAndLoadsImage() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        _ = vc.view

        let tableView = vc.value(forKey: "tableView") as! UITableView
        tableView.dataSource = vc
        tableView.delegate = vc

        let view = MockView()
        let photo = Photo(id: "1",
                          size: CGSize(width: 100, height: 100),
                          createdAt: Date(),
                          description: nil,
                          thumbImageURL: "https://example.com/thumb.jpg",
                          largeImageURL: "",
                          isLiked: true)

        let service = MockImageService()
        service.photos = [photo]

        let presenter = ImagesListPresenter(imagesService: service, tableViewWidth: 300)
        presenter.view = view
        vc.presenter = presenter

        tableView.reloadData()
        let cell = vc.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! ImagesListCell

        // Проверки
        XCTAssertTrue(view.didSetLikeIcon)
        XCTAssertEqual(view.likeIconState, true)
        XCTAssertEqual(cell.dateLabel.text?.isEmpty, false)
    }
}
