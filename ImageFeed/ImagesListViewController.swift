
import UIKit
import Foundation
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var imageListObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageListObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            let oldCount = self.tableView.numberOfRows(inSection: 0)
            self.updateTableViewAnimated(oldArrayCount: oldCount)
            
        }
        imagesListService.fetchPhotosNextPage()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let photo = imagesListService.photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController {
    
    private  func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let image = imagesListService.photos[indexPath.row]
        let url = URL(string: String(image.thumbImageURL))
        
        let placeholderImage = UIImage(named: "tableViewPlaceholder")
        cell.cellImage.contentMode = .center
        cell.cellImage.backgroundColor = UIColor(named: "YP Gray (iOS)" )
        let size: CGSize = resize(tableView, indexPath: indexPath)
        let processor = ResizingImageProcessor(referenceSize: size)
        cell.cellImage.kf.setImage(with: url, placeholder: placeholderImage, options: [.processor(processor)]) //{_ in
            //self.tableView.reloadRows(at: [indexPath], with: .automatic)
        //}
        
        guard let date = image.createdAt as Date?
        else {
            cell.dateLabel.text = ""
            return
        }
        
        //cell.dateLabel.text = dateFormatter.string(from: date)
        setLikeIcon(for: cell, indexPath: indexPath)
    }
    private func resize ( _ tableView: UITableView, indexPath: IndexPath) -> CGSize {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imagesListService.photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imagesListService.photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return CGSize(width: imageViewWidth, height: cellHeight)
    }
    
    private func setLikeIcon(for cell: ImagesListCell, indexPath: IndexPath) {
        let image = imagesListService.photos[indexPath.row]
        let isLiked = image.isLiked
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let photo = imagesListService.photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesListService.photos.count  - 1 {  //photos.count
            imagesListService.fetchPhotosNextPage()
            
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imagesListService.photos.count //photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = imagesListService.photos[indexPath.row]
        let like = photo.isLiked
        
        let likeImage = UIImage(named: like ? "like_button_off" : "like_button_on")
        cell.likeButton.setImage(likeImage, for: .normal)
        UIBlockingProgressHUD.show()
        cell.likeButton.isUserInteractionEnabled = false
        cell.isUserInteractionEnabled = false
        
        imagesListService.changeLike(photoId: photo.id, isLike: like) { [weak self] response in
            switch response {
            case .success:
                print("LIKE CHANGED")
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    cell.likeButton.isUserInteractionEnabled = true
                    cell.isUserInteractionEnabled = true
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.setLikeIcon(for: cell, indexPath: indexPath)
                    let alert = UIAlertController(title: "Ошибка", message: "Не удалось изменить лайк", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                }
                print("LIKE WAS NOT CHANGED, REASON:", error)
                UIBlockingProgressHUD.dismiss()
                cell.likeButton.isUserInteractionEnabled = true
                cell.isUserInteractionEnabled = true
            }
        }
        imagesListService.task = nil
    }
}

extension ImagesListViewController {
    
    private func updateTableViewAnimated(oldArrayCount: Int) {
        let newCount = imagesListService.photos.count
        
        guard oldArrayCount > 0 else {
            tableView.reloadData()
            return
        }
        
        guard newCount > oldArrayCount else {
            return
        }
        
        let indexPaths = (oldArrayCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates({
            tableView.insertRows(at: indexPaths, with: .automatic)
        }, completion: nil)
    }
}


