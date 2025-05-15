import UIKit
import Foundation
import Kingfisher

protocol ImagesListViewProtocol: AnyObject {
    func updateTableView()
    func insertRows(at indexPaths: [IndexPath])
    func showError(message: String)
    func setLikeIcon(for cell: ImagesListCell, isLiked: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}


final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imageListObserver: NSObjectProtocol?
    var presenter: ImagesListPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "ImagesListView"
        configureTableView()
        configurePresenter()
        configureObserver()
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let destination = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            destination.imageURL = presenter?.getImageURL(at: indexPath)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}


private extension ImagesListViewController {
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configurePresenter() {
        let service = ImagesListService.shared
        presenter = ImagesListPresenter(imagesService: service, tableViewWidth: tableView.bounds.width)
        presenter?.view = self
    }
    
    func configureObserver() {
        imageListObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableView() // 🔄 обновляем всю таблицу при любом изменении
        }
    }
    
    func updateTableViewAnimated(from oldCount: Int) {
        guard let newCount = presenter?.photosCount, newCount > oldCount else { return }
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        insertRows(at: indexPaths)
    }
}


extension ImagesListViewController: ImagesListViewProtocol {
    func updateTableView() {
        tableView.reloadData()
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func setLikeIcon(for cell: ImagesListCell, isLiked: Bool) {
        let imageName = isLiked ? "like_button_on" : "like_button_off"
        cell.likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func showLoadingIndicator() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoadingIndicator() {
        UIBlockingProgressHUD.dismiss()
    }
}


extension ImagesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photosCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageCell = cell as? ImagesListCell else { return UITableViewCell() }
        imageCell.delegate = self
        presenter?.configCell(for: imageCell, at: indexPath)
        return imageCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter?.getPhotoItemSize(at: indexPath.row).height ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}


extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        cell.likeButton.isUserInteractionEnabled = false
        cell.isUserInteractionEnabled = false
        presenter?.didTapLike(at: indexPath, cell: cell)
        cell.likeButton.isUserInteractionEnabled = true
        cell.isUserInteractionEnabled = true
    }
}

