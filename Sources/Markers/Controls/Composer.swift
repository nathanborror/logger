import UIKit

class Composer: UIControl {

    var insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8 + 30, right: 16)

    let textView = UITextView()
    let sendButton = UIButton()

    init() {
        super.init(frame: .zero)

        autoresizingMask = [.flexibleHeight]
        backgroundColor = UIColor(hex: 0xEEEEEE)

        textView.text = "Type Something..."
        textView.font = .preferredFont(forTextStyle: .body)
        textView.layer.cornerRadius = 8
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)

        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.tint, for: .normal)
        sendButton.addTarget(self, action: #selector(handleSendHit), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sendButton)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -16),

            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
            sendButton.leadingAnchor.constraint(equalTo: sendButton.leadingAnchor),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 32 + insets.top + insets.bottom)
    }

    @objc func handleSendHit() {
        sendActions(for: .primaryActionTriggered)
    }
}
