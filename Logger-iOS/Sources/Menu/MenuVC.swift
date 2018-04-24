import UIKit
import LoggerKit

class MenuVC: UIViewController, MenuPresentable {

    var entry: Entry!
    var sourceRect: CGRect = .zero

    let stackView = UIStackView()
    let deleteButton = UIButton(type: .system)
    let searchButton = UIButton(type: .system)

    convenience init(entry: Entry) {
        self.init(nibName: nil, bundle: nil)
        self.entry = entry
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        deleteButton.setImage(.iconTrash, for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(handleDelete), for: .primaryActionTriggered)

        searchButton.setImage(.iconSearch, for: .normal)
        searchButton.tintColor = .systemBlue
        searchButton.addTarget(self, action: #selector(handleSearch), for: .primaryActionTriggered)

        stackView.distribution = .fillEqually
        stackView.frame = view.bounds
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.addArrangedSubview(deleteButton)
        stackView.addArrangedSubview(searchButton)
        view.addSubview(stackView)
    }

    @objc func handleSearch() {
        defer { dismiss(animated: true, completion: nil) }
        let cleaned = entry.text.replace(regex: "#(\\w+\\s?)", with: "")
        let query = cleaned.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: "https://google.com/search?q=\(query)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func handleDelete() {
        defer { dismiss(animated: true, completion: nil) }
        try! Kit.entryDelete(entry: entry)
    }
}

extension MenuVC: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return MenuPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MenuAnimator()
        animator.isPresenting = false
        return animator
    }
}
