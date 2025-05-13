
import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    
    @IBOutlet private var webView: WKWebView!
    weak var delegate: WebViewViewControllerDelegate?
    @IBOutlet private var progressView: UIProgressView!
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    var presenter: WebViewPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 //self.updateProgress()
                 self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
             })
        
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        //loadAuthView()
        
        let backButton = UIButton(type: .system)
        let backImage = UIImage(named: "nav_back_button")
        backButton.setImage(backImage, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //    private func updateProgress() {
    //        progressView.progress = Float(webView.estimatedProgress)
    //        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    //    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    private func loadAuthView() {
        //        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
        //            return
        //        }
        //
        //        urlComponents.queryItems = [
        //            URLQueryItem(name: "client_id", value: Constants.accessKey),
        //            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
        //            URLQueryItem(name: "response_type", value: "code"),
        //            URLQueryItem(name: "scope", value: Constants.accessScope)
        //        ]
        //
        //        guard let url = urlComponents.url else {
        //            return
        //        }
        //
        //        let request = URLRequest(url: url)
        ////        webView.load(request)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        //        guard let url = navigationAction.request.url else {
        //            print("No URL found in navigationAction.")
        //            return nil
        //        }
        //
        //        guard let urlComponents = URLComponents(string: url.absoluteString) else {
        //            print("Failed to get URLComponents from: ", url.absoluteString)
        //            return nil
        //        }
        //
        //        guard urlComponents.path == "/oauth/authorize/native" else {
        //            print("URL's do not match.")
        //            return nil
        //        }
        //
        //        guard let codeItem = urlComponents.queryItems?.first(where: { $0.name == "code" }) else {
        //            print("No such item as code found.")
        //            return nil
        //        }
        //
        //        return codeItem.value
        //    }
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}
