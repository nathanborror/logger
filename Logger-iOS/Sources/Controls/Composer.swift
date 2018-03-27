import UIKit

extension UIControlEvents {
    static var searchQueryChanged: UIControlEvents = [.valueChanged]
}

class Composer: UIControl {

    var insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    var text: String? {
        guard isPlaceholding != true else { return nil }
        guard textView.text != "" else { return nil }
        return textView.text
    }

    var query: String? {
        get {
            guard searchIcon.isHidden == false else { return nil }
            guard isPlaceholding == false else { return nil }
            return textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set {
            if newValue == nil {
                searchModeOff()
            } else {
                searchModeOn()
                placeholderOff(with: newValue!)
            }
        }
    }

    var placeholder = "Type Something..."
    var placeholderColor = UIColor.lightGray
    var isPlaceholding = true

    let contentView = UIView()
    let textView = UITextView()
    let searchIcon = UIImageView()
    let clearButton = UIButton()

    var textViewHeightAnchor: NSLayoutConstraint!

    init() {
        super.init(frame: .zero)

        autoresizingMask = [.flexibleHeight]
        backgroundColor = UIColor(white: 0.9, alpha: 1)

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

        searchIcon.image = .iconSearch
        searchIcon.tintColor = .black
        searchIcon.layer.cornerRadius = 6
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.isHidden = true
        contentView.addSubview(searchIcon)

        clearButton.setImage(.iconClear, for: .normal)
        clearButton.tintColor = .lightGray
        clearButton.isHidden = true
        clearButton.addTarget(self, action: #selector(handleClearSearch), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clearButton)

        textViewHeightAnchor = textView.heightAnchor.constraint(equalToConstant: 96)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),

            searchIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(insets.bottom + 8)),
            searchIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: (insets.left + 6)),
            searchIcon.widthAnchor.constraint(equalToConstant: 24),
            searchIcon.heightAnchor.constraint(equalToConstant: 24),

            clearButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(insets.bottom - 3)),
            clearButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            clearButton.widthAnchor.constraint(equalToConstant: 44),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        reload()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 32 + insets.top + insets.bottom)
    }

    func reload() {
        placeholderOn()
    }

    // MARK: - Placeholder

    private func placeholderOff(with value: String = "") {

        // Must be set before setting the text attribute otherwise
        // the cursor won't appear at the end of the text.
        isPlaceholding = false

        textView.text = value
        textView.textColor = .black
    }

    private func placeholderOn() {
        textView.text = placeholder
        textView.textColor = placeholderColor
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)

        // Must be set after setting the text view text otherwise it
        // will cause an infinite loop with textViewDidChangeSelection().
        isPlaceholding = true
    }

    // MARK: - Search

    @objc private func handleClearSearch() {
        reload()
        searchModeOff()
    }

    private func searchModeOn() {
        guard searchIcon.isHidden else {
            return
        }
        searchIcon.isHidden = false
        clearButton.isHidden = false
        var textInsets = textView.textContainerInset
        textInsets.left += 32
        textView.textContainerInset = textInsets
    }

    private func searchModeOff() {
        guard searchIcon.isHidden == false else {
            return
        }
        searchIcon.isHidden = true
        clearButton.isHidden = true
        var textInsets = textView.textContainerInset
        textInsets.left -= 32
        textView.textContainerInset = textInsets

        // TODO: Figure out exactly why this is necessary
        searchQueryChanged()
    }

    private func searchQueryChanged() {
        sendActions(for: .searchQueryChanged)
    }
}

extension Composer: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // Return early and submit on newline character
        guard text != "\n" else { sendActions(for: .primaryActionTriggered); return false }

        // Show Search Mode when first character is a space character
        if text == " " && range.length == 0 && range.location == 0 { searchModeOn(); return false }

        // Dismiss Search Mode when first character is an empty character
        if text == "" && range.length == 0 && range.location == 0 { searchModeOff(); return false }

        // Determine the new text value
        let oldText = textView.text ?? ""
        let newText = oldText.replacingCharacters(in: Range(range, in: oldText)!, with: text)

        // Return early and replace with placeholder when new text is empty
        guard newText.isEmpty != true else {
            placeholderOn()
            if searchIcon.isHidden == false { searchQueryChanged() }
            return false
        }

        // Prepare text view for a value
        if textView.text == placeholder && !text.isEmpty {
            placeholderOff(with: "")
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {

        if textView.bounds.height >= textViewHeightAnchor.constant {
            textView.isScrollEnabled = true
            textViewHeightAnchor.isActive = true
        } else {
            textView.isScrollEnabled = false
            textViewHeightAnchor.isActive = false
        }

        // HACK: Ensure text color is correct, color wasn't changing when pasting
        // into the text view. Setting it here ensures it will be the correct color.
        // This could be fixed in later release of iOS, unclear if this is a bug.
        textView.textColor = isPlaceholding ? placeholderColor : .black

        if searchIcon.isHidden == false {
            searchQueryChanged()
            return
        }
    }

    func textViewDidChangeSelection(_ textView: UITextView) {

        // Prevent repositioning of the cursor while displaying placeholder
        guard isPlaceholding else { return }
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
}
