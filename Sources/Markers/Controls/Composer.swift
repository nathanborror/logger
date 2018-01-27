import UIKit

class Composer: UIControl {

    var placeholder = "Type Something..."
    var placeholderColor = UIColor.lightGray
    var insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    var text: String? {
        guard textView.text != placeholder else { return nil }
        guard textView.text != "" else { return nil }
        return textView.text
    }

    private let contentView = UIView()
    private let textView = UITextView()

    init() {
        super.init(frame: .zero)

        autoresizingMask = [.flexibleHeight]
        backgroundColor = UIColor(hex: 0xEEEEEE)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        textView.delegate = self
        textView.font = .preferredFont(forTextStyle: .body)
        textView.layer.cornerRadius = 8
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.returnKeyType = .send
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
        ])

        // Show placeholder text initially
        showPlaceholderText()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 32 + insets.top + insets.bottom)
    }

    public func clear() {
        showPlaceholderText()
    }

    private func handleSendHit() {
        sendActions(for: .primaryActionTriggered)
    }

    private func showPlaceholderText() {
        textView.text = placeholder
        textView.textColor = placeholderColor
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }

    private func showEmptyText() {
        textView.text = ""
        textView.textColor = .black
    }
}

extension Composer: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else {
            handleSendHit()
            return false
        }

        // Combine the textView text and the replacement text to create the
        // updated text string
        let currentText = textView.text
        let updatedText = currentText?.replacingCharacters(in: Range(range, in: currentText ?? "")!, with: text)

        // If updated textView will be empty, add the placeholder and set the
        // cursor to the beginning of the textView
        if updatedText!.isEmpty {
            showPlaceholderText()
            return false
        } else if textView.textColor == placeholderColor && !text.isEmpty {
            showEmptyText()
        }
        return true
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.textColor == placeholderColor {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
}
