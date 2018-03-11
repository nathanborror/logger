import UIKit
import Differ

extension UITableView {

    /// Applies a batch update to the receiver, efficiently reporting changes between old and new.
    /// This version tries to fix bugs in the library implementation
    ///
    /// - parameter old:            The previous state of the collection view.
    /// - parameter new:            The current state of the collection view.
    /// - parameter updateData:     Block for caller to update the data that underlies collection view dataSource.
    func applyDiff<T: Collection>(prior: T, section: Int = 0, animation: UITableViewRowAnimation = .automatic, updateData: () -> T) where T.Iterator.Element: Hashable, T.IndexDistance == Int, T.Index == Int {
        var update: ListUpdate?

        performBatchUpdates({
            let new = updateData() // Let caller update data underlying dataSource
            update = ListUpdate(diff(prior, new), section)
            if update!.deletions.count > 0 {
                self.deleteRows(at: update!.deletions, with: animation)
            }
            if update!.insertions.count > 0 {
                self.insertRows(at: update!.insertions, with: animation)
            }
            if update!.moves.count > 0 {
                for move in update!.moves {
                    self.moveRow(at: move.from, to: move.to)
                }
            }
        }, completion: nil)

        // reloadItems is done separately as the update indexes return by diff() are in respect to the
        // "after" state, but the collectionView.reloadItems() call wants the "before" indexPaths.
        performBatchUpdates({
            self.reloadRows(at: update!.updates, with: animation)
        })
    }
}
