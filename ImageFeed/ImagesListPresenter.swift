import UIKit
import Foundation
import Kingfisher

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    var photosCount: Int { get }

    func viewDidLoad()
    func getPhotoItemSize(at index: Int) -> CGSize
    func configCell(for cell: ImagesListCell, at indexPath: IndexPath)
    func didSelectRow(at indexPath: IndexPath)
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath, cell: ImagesListCell)
    func getImageURL(at indexPath: IndexPath) -> URL?
}


final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    private let imagesService: ImagesListServiceProtocol
    private let tableViewWidth: CGFloat
    private let dateFormatter: DateFormatter

    init(imagesService: ImagesListServiceProtocol, tableViewWidth: CGFloat) {
        self.imagesService = imagesService
        self.tableViewWidth = tableViewWidth
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .none
    }

    var photosCount: Int {
        return imagesService.photos.count
    }

    func viewDidLoad() {
        fetchPhotos()
    }

    private func fetchPhotos() {
        imagesService.fetchPhotosNextPage { [weak self] result in
            guard let self = self else { return }
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self.view?.showError(message: "Ошибка загрузки: \(error.localizedDescription)")
                }
            }
        }
    }

    func getPhotoItemSize(at index: Int) -> CGSize {
        let photo = imagesService.photos[index]
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let width = tableViewWidth - insets.left - insets.right
        let scale = width / photo.size.width
        let height = photo.size.height * scale + insets.top + insets.bottom
        return CGSize(width: width, height: height)
    }

    func configCell(for cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = imagesService.photos[indexPath.row]
        let model = ImagesListCellModel(
            imageURL: URL(string: photo.thumbImageURL),
            date: photo.createdAt.map { dateFormatter.string(from: $0) } ?? "",
            isLiked: photo.isLiked
        )
        let size = getPhotoItemSize(at: indexPath.row)
        configureCell(cell, with: model, size: size)
        view?.setLikeIcon(for: cell, isLiked: model.isLiked)
    }

    private func configureCell(_ cell: ImagesListCell, with model: ImagesListCellModel, size: CGSize) {
        let placeholder = UIImage(named: "tableViewPlaceholder")
        cell.cellImage.contentMode = .center
        cell.cellImage.backgroundColor = UIColor(named: "YP Gray (iOS)")
        let processor = ResizingImageProcessor(referenceSize: size)
        cell.cellImage.kf.setImage(
            with: model.imageURL,
            placeholder: placeholder,
            options: [.processor(processor)]
        )
        cell.dateLabel.text = model.date
    }

    func didSelectRow(at indexPath: IndexPath) {
    }

    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == imagesService.photos.count - 1 {
            fetchPhotos()
        }
    }
    
    func didTapLike(at indexPath: IndexPath, cell: ImagesListCell) {
        let photo = imagesService.photos[indexPath.row]
        view?.showLoadingIndicator()

        cell.likeButton.isUserInteractionEnabled = false
        cell.isUserInteractionEnabled = false

        imagesService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.view?.hideLoadingIndicator()

                cell.likeButton.isUserInteractionEnabled = true
                cell.isUserInteractionEnabled = true

                switch result {
                case .success:
                    break
                case .failure(let error):
                    print("Ошибка при изменении лайка: \(error.localizedDescription)")
                    self.view?.showError(message: "Не удалось изменить лайк")
                    self.view?.setLikeIcon(for: cell, isLiked: photo.isLiked)
                }
            }
        }
    }
    

    func getImageURL(at indexPath: IndexPath) -> URL? {
        let photo = imagesService.photos[indexPath.row]
        return URL(string: photo.largeImageURL)
    }
    
}

