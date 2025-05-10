
import UIKit

final class SingleImageViewController: UIViewController {
    var imageURL: URL?
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image = image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    private var scrollViewVisibleSize: CGSize {
        let contentInset = scrollView.contentInset
        let scrollViewSize = scrollView.bounds.standardized.size
        let width = scrollViewSize.width - contentInset.left - contentInset.right
        let height = scrollViewSize.height - contentInset.top - contentInset.bottom
        return CGSize(width:width, height:height)
    }
    
    private var scrollViewCenter: CGPoint {
        let scrollViewSize = self.scrollViewVisibleSize
        return CGPoint(x: scrollViewSize.width / 2.0,
                       y: scrollViewSize.height / 2.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.sendSubviewToBack(imageView)
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        setPlaceholderImage()
        
        guard let url = imageURL else { return }
        
        imageView.kf.setImage(with: url) { result in
            switch result {
            case .success(let value):
                if let safeUrl = value.source.url {
                    print("Task done for \(safeUrl)")
                } else {
                    print("Task done, but URL is nil")
                }
                self.imageView.subviews.last?.removeFromSuperview()
                UIBlockingProgressHUD.dismiss()
                
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Ошибка", message: "Не удалось загрузить изображение", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                }
            }
        }
        
        guard let image = image else { return }
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    private func setPlaceholderImage() {
        UIBlockingProgressHUD.show()
        
        let placeholderImage = UIImage(named: "table_view_placeholder")
        let placeholderUI = UIImageView(image: placeholderImage)
        placeholderUI.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(placeholderUI)
        
        NSLayoutConstraint.activate([
            placeholderUI.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderUI.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func centerScrollViewContents() {
        guard let image = imageView.image else {
            return
        }
        
        let imgViewSize = imageView.frame.size
        let imageSize = image.size
        
        var realImgSize: CGSize
        if imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height {
            realImgSize = CGSize(width: imgViewSize.width,height: imgViewSize.width / imageSize.width * imageSize.height)
        } else {
            realImgSize = CGSize(width: imgViewSize.height / imageSize.height * imageSize.width, height: imgViewSize.height)
        }
        
        var frame = CGRect.zero
        frame.size = realImgSize
        imageView.frame = frame
        
        let screenSize  = scrollView.frame.size
        let offx = screenSize.width > realImgSize.width ? (screenSize.width - realImgSize.width) / 2 : 0
        let offy = screenSize.height > realImgSize.height ? (screenSize.height - realImgSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: offy,
                                               left: offx,
                                               bottom: offy,
                                               right: offx)
        
        let scrollViewSize = scrollViewVisibleSize
        
        var imageCenter = CGPoint(x: scrollView.contentSize.width / 2.0,
                                  y: scrollView.contentSize.height / 2.0)
        
        let center = scrollViewCenter
        
        if scrollView.contentSize.width < scrollViewSize.width {
            imageCenter.x = center.x
        }
        
        if scrollView.contentSize.height < scrollViewSize.height {
            imageCenter.y = center.y
        }
        
        imageView.center = imageCenter
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
