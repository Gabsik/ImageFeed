
import XCTest
@testable import ImageFeed

class ImageFeedTests: XCTestCase {
    
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper() //Dummy
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress) // return value verification
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        guard let url = authHelper.authURL() else {
                XCTFail("authURL() вернул nil")
                return
            }
        let urlString = url.absoluteString
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        // given
        let urlString = "https://unsplash.com/oauth/authorize/native"
        guard var urlComponents = URLComponents(string: urlString) else {
            XCTFail("Не удалось создать URLComponents из строки: \(urlString)")
            return
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        
        guard let url = urlComponents.url else {
            XCTFail("Не удалось получить URL из URLComponents")
            return
        }
        
        let authHelper = AuthHelper()
        
        // when
        let code = authHelper.code(from: url)
        
        // then
        XCTAssertEqual(code, "test code")
    }
    //
    //    override func setUpWithError() throws {
    //        // Put setup code here. This method is called before the invocation of each test method in the class.
    //    }
    //
    //    override func tearDownWithError() throws {
    //        // Put teardown code here. This method is called after the invocation of each test method in the class.
    //    }
    //
    //    func testExample() throws {
    //        // This is an example of a functional test case.
    //        // Use XCTAssert and related functions to verify your tests produce the correct results.
    //    }
    //
    //    func testPerformanceExample() throws {
    //        // This is an example of a performance test case.
    //        measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
}
