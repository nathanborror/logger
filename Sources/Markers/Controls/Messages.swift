import UIKit
import Kit

class MessagesController {

    let messageDisplayTimeout: TimeInterval = 2

    private let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    private let messageView = MessageView()

    private var model = MessagesModel()
    private var timeout: Timer? = nil

    func makeChild(of view: UIView) {
        messageView.isHidden = true
        messageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageView)

        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            messageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            messageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])

        Kit.subscribe(self, action: MessagesController.messagesUpdate)
    }

    private func messagesUpdate(messages: [Message]) {
        if model.applyInbox(messages) {
            displayMessage()
        }
    }

    private func displayMessage() {
        
        // Only continue if the Inbox has messages and we're not already
        // displaying a message.
        guard messageView.isHidden, let message = model.readNext() else { return }

        messageView.apply(message: message)

        // Ensure view is visible above all other sibling views
        messageView.superview?.bringSubview(toFront: messageView)
        messageView.isHidden = false

        let startY = (messageView.bounds.height / 2) + (messageView.superview?.safeAreaInsets.top ?? 0)
        let startPoint = CGPoint(x: messageView.center.x, y: -startY)
        let endPoint = CGPoint(x: messageView.center.x, y: (messageView.bounds.height / 2) + (messageView.superview?.safeAreaInsets.top ?? 0))
        animate(from: startPoint, to: endPoint)

        // Timeout message
        timeout = Timer.scheduledTimer(timeInterval: messageDisplayTimeout, target: self, selector: #selector(removeMessage),
                                         userInfo: nil, repeats: false)
    }

    @objc private func removeMessage() {
        let startPoint = messageView.center
        let endY = (messageView.bounds.height / 2) + (messageView.superview?.safeAreaInsets.top ?? 0)
        let endPoint = CGPoint(x: messageView.center.x, y: -endY)
        animate(from: startPoint, to: endPoint) {
            self.messageView.isHidden = true
            self.displayMessage()
        }
        timeout?.invalidate()
        timeout = nil
    }

    private func animate(from: CGPoint, to: CGPoint, completion: (() -> Void)? = nil) {
        messageView.center = from
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: [], animations: {
            self.messageView.center = to
        }, completion: { (finished) in
            completion?()
        })
    }
}

struct MessagesModel {
    var inbox: [Message] = []

    mutating func applyInbox(_ messages: [Message]) -> Bool {
        inbox += messages
        return true
    }

    mutating func readNext() -> Message? {
        return inbox.popLast()
    }
}

class MessageView: UIVisualEffectView {

    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let textLabel = UILabel()

    init() {
        super.init(effect: blurEffect)

        layer.cornerRadius = 12
        layer.masksToBounds = true

        textLabel.textColor = .white
        textLabel.numberOfLines = 2
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)

        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(message: Message) {
        switch message.level {
        case .debug:
            textLabel.text = message.message
        case .info:
            textLabel.text = message.message
        case .success:
            textLabel.text = message.message
        case .warning:
            textLabel.text = message.message
        case .error:
            textLabel.text = message.message
        }
    }
}
