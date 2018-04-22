import UIKit

extension UIViewController {

    func presentOverKeyboard(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let rootVC = UIApplication.shared.windows.last?.rootViewController else {
            present(viewController, animated: animated, completion: completion)
            return
        }
        rootVC.present(viewController, animated: animated, completion: completion)
    }
}
