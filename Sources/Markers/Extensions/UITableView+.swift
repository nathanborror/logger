import UIKit

extension UITableView {

    func apply<T: Collection>(old: T, new: T, section: Int, animation: UITableViewRowAnimation, reload: Bool = true) where T.Iterator.Element: Hashable, T.IndexDistance == Int, T.Index == Int {
        let update = ListUpdate(diff(old, new), section)

        beginUpdates()

        deleteRows(at: update.deletions, with: animation)
        insertRows(at: update.insertions, with: animation)
        for move in update.moves {
            moveRow(at: move.from, to: move.to)
        }
        endUpdates()

        // reloadItems is done separately as the update indexes returne by diff() are in respect to the
        // "after" state, but the collectionView.reloadItems() call wants the "before" indexPaths.
        if reload && update.updates.count > 0 {
            beginUpdates()
            reloadRows(at: update.updates, with: animation)
            endUpdates()
        }
    }
}
