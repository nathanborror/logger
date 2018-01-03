import UIKit

extension UIViewController {

    func addChild(_ vc: UIViewController) {
        vc.willMove(toParentViewController: self)
        view.addSubview(vc.view)
        addChildViewController(vc)
        vc.didMove(toParentViewController: self)
    }

    func removeFromParent() {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}
