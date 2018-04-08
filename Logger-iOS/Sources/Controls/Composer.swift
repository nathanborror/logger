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
    var isSearching: Bool { return !searchIcon.isHidden }

    let contentView = UIView()
    let textView = UITextView()
    let searchIcon = UIImageView()
    let primaryButton = PrimaryButton()

    var textViewHeightAnchor: NSLayoutConstraint!

    init() {
        super.init(frame: .zero)

        autoresizingMask = [.flexibleHeight]
        backgroundColor = .white

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        textView.delegate = self
        textView.font = .preferredFont(forTextStyle: .body)
        textView.layer.cornerRadius = 19
        textView.layer.borderColor = UIColor(white: 0.7, alpha: 1).cgColor
        textView.layer.borderWidth = 1 / UIScreen.main.scale
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.keyboardType = .twitter
        textView.backgroundColor = UIColor(white: 0.98, alpha: 1)
        textView.tintColor = .black
        contentView.addSubview(textView)

        searchIcon.image = .iconSearch
        searchIcon.tintColor = .black
        searchIcon.layer.cornerRadius = 6
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.isHidden = true
        contentView.addSubview(searchIcon)

        primaryButton.stage = .photo
        primaryButton.addTarget(self, action: #selector(handlePrimaryTapped), for: .primaryActionTriggered)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(primaryButton)

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

            searchIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(insets.bottom + 7)),
            searchIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: (insets.left + 8)),
            searchIcon.widthAnchor.constraint(equalToConstant: 24),
            searchIcon.heightAnchor.constraint(equalToConstant: 24),

            primaryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(insets.bottom + 5)),
            primaryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -13),
            primaryButton.widthAnchor.constraint(equalToConstant: 28),
            primaryButton.heightAnchor.constraint(equalToConstant: 28),
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

    @objc private func handlePrimaryTapped() {
        switch primaryButton.stage {
        case .send:
            sendActions(for: .primaryActionTriggered)
        case .photo:
            sendActions(for: .photoPickerShouldShow)
        case .clear:
            reload()
            searchModeOff()
        case .none:
            break
        }
    }

    // MARK: - Placeholder

    private func placeholderOff(with value: String = "") {

        // Must be set before setting the text attribute otherwise
        // the cursor won't appear at the end of the text.
        isPlaceholding = false

        textView.text = value
        textView.textColor = .black

        primaryButton.stage = isSearching ? .clear : .send
    }

    private func placeholderOn() {
        textView.text = placeholder
        textView.textColor = placeholderColor
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)

        // Must be set after setting the text view text otherwise it
        // will cause an infinite loop with textViewDidChangeSelection().
        isPlaceholding = true

        primaryButton.stage = isSearching ? .clear : .photo
    }

    // MARK: - Search

    private func searchModeOn() {
        guard searchIcon.isHidden else {
            return
        }
        searchIcon.isHidden = false
        var textInsets = textView.textContainerInset
        textInsets.left += 18
        textView.textContainerInset = textInsets

        primaryButton.stage = .clear
    }

    private func searchModeOff() {
        guard searchIcon.isHidden == false else {
            return
        }
        searchIcon.isHidden = true
        var textInsets = textView.textContainerInset
        textInsets.left -= 18
        textView.textContainerInset = textInsets

        // TODO: Figure out exactly why this is necessary
        searchQueryChanged()

        primaryButton.stage = .photo
    }

    private func searchQueryChanged() {
        sendActions(for: .searchQueryChanged)
    }
}

extension Composer: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

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

    func textViewDidBeginEditing(_ textView: UITextView) {
        sendActions(for: .editingDidBegin)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        sendActions(for: .editingDidEnd)
    }
}

class PrimaryButton: UIControl {

    enum Stage {
        case send
        case photo
        case clear
        case none
    }

    var stage: Stage = .none { didSet{ stageDidSet() }}

    private let background = CALayer()

    convenience init() {
        self.init(frame: .zero)

        background.frame = bounds
        background.backgroundColor = UIColor.systemBlue.cgColor
        layer.addSublayer(background)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapped))
        addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        animateBackground()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let frame = bounds.insetBy(dx: -20, dy: -20)
        return frame.contains(point)
    }

    @objc func handleTapped() {
        sendActions(for: .primaryActionTriggered)
    }

    func stageDidSet() {
        animateBackground()
    }

    func animateBackground() {
        switch stage {
        case .send:
            background.backgroundColor = UIColor.systemBlue.cgColor
            background.frame = bounds
            background.contents = UIImage.iconArrowUp.cgImage
        case .photo:
            background.backgroundColor = UIColor(hex: 0x8E8E93).cgColor
            background.frame = bounds
            background.contents = UIImage.iconCamera.cgImage
        case .clear:
            background.backgroundColor = UIColor(hex: 0x8E8E93).cgColor
            background.frame = bounds.insetBy(dx: 7, dy: 7)
            background.contents = UIImage.iconClear.cgImage
        case .none:
            background.backgroundColor = UIColor.clear.cgColor
            background.frame = bounds
            background.contents = nil
        }
        background.cornerRadius = background.frame.height / 2
    }
}
