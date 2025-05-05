
import UIKit
import Foundation

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    //    private let photosName: [String] = Array(0..<20).map { "\($0)" }
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imageListObserver: NSObjectProtocol?
    
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imageListObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let updatedPhotos = notification.userInfo?["photos"] as? [Photo] {
                print("Before update: \(self.photos.count)")
                self.photos = updatedPhotos
                print("After update: \(self.photos.count)")
                self.updateTableView()
            }
        }
        
        imagesListService.fetchPhotosNextPage()
    }
    
    private func updateTableView() {
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = photos.count
        
        guard newCount > oldCount else { return }
        
        let newIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates({
            tableView.insertRows(at: newIndexPaths, with: .automatic)
        }, completion: nil)
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
            let photo = photos[indexPath.row]
            //let image = UIImage(named: photosName[indexPath.row])
            //viewController.image = image
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        
        let url = URL(string: photo.largeImageURL)
        cell.setImage(with: url)
        
        let date = photo.createdAt.map { dateFormatter.string(from: $0) } ?? " "
        let isLiked = photo.isLiked
        let model = ImagesListCellModel(imageURL: url, date: date, isLiked: isLiked)
        cell.configure(with: model)
        //        guard let image = UIImage(named: photosName[indexPath.row]) else {
        //            return
        //        }
        //        cell.cellImage.image = image
        //        cell.dateLabel.text = dateFormatter.string(from: Date())
        //
        //        let isLiked = indexPath.row % 2 == 0
        //        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        //        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
        //        guard let image = UIImage(named: photosName[indexPath.row]) else {
        //            return 0
        //        }
        //
        //        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        //        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        //        let imageWidth = image.size.width
        //        let scale = imageViewWidth / imageWidth
        //        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        //        return cellHeight
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
            
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //photosName.count
        photos.count
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
        
        var photo = photos[indexPath.row]
        photo.isLiked.toggle()
        
        photos[indexPath.row] = photo
        cell.setIsLiked(photo.isLiked)
    }
}

//extension ImagesListViewController {
//    func tableView(
//        _ tableView: UITableView,
//        willDisplay cell: UITableViewCell,
//        forRowAt indexPath: IndexPath
//    ) {
//        if indexPath.row + 1 == imagesListService.photos.count {
//            imagesListService.fetchPhotosNextPage()
//        }
//    }
//}

