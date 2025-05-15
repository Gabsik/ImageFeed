

import Foundation
import UIKit

final class UITableViewSpy: UITableView {
    var didCallReloadData = false
    var didCallInsertRows = false

    override func reloadData() {
        didCallReloadData = true
        super.reloadData()
    }

    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        didCallInsertRows = true
        super.performBatchUpdates(updates, completion: completion)
    }
}
