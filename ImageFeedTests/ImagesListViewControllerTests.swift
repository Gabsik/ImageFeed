
import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {

    // MARK: - Mocks

    final class MockPresenter: ImagesListPresenterProtocol {
        weak var view: ImagesListViewProtocol?
        var photosCount: Int = 10

        var didCallViewDidLoad = false
        var didCallWillDisplayCell = false
        var didCallConfigCell = false
        var didCallDidTapLike = false
        var didCallGetImageURL = false

        func viewDidLoad() { didCallViewDidLoad = true }
        func getPhotoItemSize(at index: Int) -> CGSize { CGSize(width: 100, height: 100) }
        func configCell(for cell: ImagesListCell, at indexPath: IndexPath) { didCallConfigCell = true }
        func didSelectRow(at indexPath: IndexPath) {}
        func willDisplayCell(at indexPath: IndexPath) { didCallWillDisplayCell = true }
        func didTapLike(at indexPath: IndexPath, cell: ImagesListCell) { didCallDidTapLike = true }
        func getImageURL(at indexPath: IndexPath) -> URL? {
            didCallGetImageURL = true
            return URL(string: "https://example.com/image.jpg")
        }
    }

    class UITableViewSpy: UITableView {
        var didCallReloadData = false
        var didCallInsertRows = false

        override func reloadData() {
            didCallReloadData = true
        }

        override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
            updates?()
            completion?(true)
        }

        override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
            didCallInsertRows = true
        }
    }

    // MARK: - Test properties

    var sut: ImagesListViewController!
    var mockPresenter: MockPresenter!

    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController

        _ = sut.view

        mockPresenter = MockPresenter()
        sut.presenter = mockPresenter
        sut.presenter?.viewDidLoad()
    }

    override func tearDown() {
        sut = nil
        mockPresenter = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testViewDidLoadCallsPresenter() {
        XCTAssertTrue(mockPresenter.didCallViewDidLoad, "Presenter.viewDidLoad() не был вызван")
    }

    func testUpdateTableViewReloadsData() {
        let tableView = UITableViewSpy()
        sut.setValue(tableView, forKey: "tableView")
        sut.updateTableView()
        XCTAssertTrue(tableView.didCallReloadData)
    }

    func testInsertRowsCallsBatchUpdates() {
        let tableView = UITableViewSpy()
        sut.setValue(tableView, forKey: "tableView")
        let indexPaths = [IndexPath(row: 0, section: 0)]
        sut.insertRows(at: indexPaths)
        XCTAssertTrue(tableView.didCallInsertRows)
    }

    func testShowErrorPresentsAlert() {
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()

        sut.showError(message: "Ошибка теста")

        let presented = sut.presentedViewController as? UIAlertController
        XCTAssertNotNil(presented)
        XCTAssertEqual(presented?.message, "Ошибка теста")
    }

    func testTableViewDataSourceReturnsCorrectCount() {
        let tableView = UITableView()
        sut.setValue(tableView, forKey: "tableView")
        tableView.dataSource = sut

        mockPresenter.photosCount = 10

        let count = sut.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(count, 10)
    }

    func testWillDisplayCellCallsPresenter() {
        let tableView = UITableView()
        sut.setValue(tableView, forKey: "tableView")
        tableView.delegate = sut

        let cell = UITableViewCell()
        sut.tableView(tableView, willDisplay: cell, forRowAt: IndexPath(row: 9, section: 0))
        XCTAssertTrue(mockPresenter.didCallWillDisplayCell)
    }

}
