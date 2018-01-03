import UIKit
import Kit

class RootVC: UIViewController {

    private let mainController: UIViewController
    private let messageController: MessagesController

    init(mainController: UIViewController) {
        self.mainController = mainController
        self.messageController = MessagesController()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(mainController)
        messageController.makeChild(of: view)
    }
}
