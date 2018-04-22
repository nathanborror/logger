import UIKit

protocol MenuPresentable {
    var sourceRect: CGRect { get }
}

class MenuPresentationController: UIPresentationController {

    let dimmingView = UIView()

    var sourceRect: CGRect {
        return (presentedViewController as? MenuPresentable)?.sourceRect ?? .zero
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        dimmingView.addGestureRecognizer(tap)
    }

    override func presentationTransitionWillBegin() {

        let path = CGMutablePath()
        path.addRect(sourceRect)
        path.addRect(containerView?.bounds ?? .zero)

        let mask = CAShapeLayer()
        mask.path = path
        mask.fillRule = kCAFillRuleEvenOdd

        dimmingView.frame = containerView?.bounds ?? .zero
        dimmingView.backgroundColor = .background
        dimmingView.alpha = 0
        dimmingView.layer.mask = mask
        containerView?.insertSubview(dimmingView, at: 0)

        var startFrame = frameOfPresentedViewInContainerView
        startFrame.origin.y += 2

        presentedViewController.view.frame = startFrame
        presentedViewController.view.alpha = 0
        presentedViewController.view.layer.cornerRadius = 10
        presentedViewController.view.layer.shadowColor = UIColor.black.cgColor
        presentedViewController.view.layer.shadowRadius = 15
        presentedViewController.view.layer.shadowOpacity = 0.3
        presentedViewController.view.layer.shadowOffset = CGSize(width: 0, height: 4)

        let animations = {
            self.dimmingView.alpha = 0.4
            self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
        }

        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                animations()
            }, completion: nil)
        } else {
            animations()
        }
    }

    override func dismissalTransitionWillBegin() {
        let animations = {
            self.dimmingView.alpha = 0
        }

        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                animations()
            }, completion: nil)
        } else {
            animations()
        }
    }

    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return presentedViewController.preferredContentSize
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        let size = self.size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        var origin = CGPoint(x: sourceRect.minX, y: sourceRect.minY - (size.height + 1))
        // Adjust Y position when so it doesn't get clipped by the top of the scroll view
        if origin.y < 0 { origin.y = sourceRect.maxY + 1 }
        return CGRect(origin: origin, size: size)
    }

    @objc func handleDismiss() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

class MenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting = true

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        var viewController: UIViewController!

        if isPresenting {
            viewController = context.viewController(forKey: .to)!
            viewController.view.alpha = 0
            containerView.addSubview(viewController.view)
        } else {
            viewController = context.viewController(forKey: .from)!
        }

        UIView.animate(withDuration: transitionDuration(using: context), animations: {
            viewController.view.alpha = self.isPresenting ? 1 : 0
        }, completion: { finished in
            context.completeTransition(finished)
        })
    }
}
