
import Foundation
import UIKit
import Kingfisher

struct ImagesListCellModel {
    let imageURL: URL?
    let date: String
    let isLiked: Bool
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
////        likeButton.setImage(UIImage(named: "NoActive"), for: .normal)
////        likeButton.setImage(UIImage(named: "ActiveLike"), for: .selected)
//    }
//
//    func setImage(with url: URL?) {
//        cellImage.kf.setImage(
//            with: url,
//            placeholder: UIImage(named: "placeholder"),
//            options: [.transition(.fade(0.3))]
//        )
//    }
//
//    func setIsLiked(_ isLiked: Bool) {
//        likeButton.isSelected = isLiked
//    }
//    func configure(with model: ImagesListCellModel) {
//        setImage(with: model.imageURL)
//        dateLabel.text = model.date
//        setIsLiked(model.isLiked)
//    }
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
