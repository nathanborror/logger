import UIKit

class FormTextAreaCell: UITableViewCell, UITextViewDelegate {
    
    var labelInset = UIEdgeInsets(top: 5, left: 16, bottom: 0, right: 15)
    var fieldInset = UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16)
    var value: String? {
        return fieldView.text
    }
    var didUpdate: (() -> Void)?
    
    private(set) lazy var labelView: UILabel = {
        let view = UILabel()
        self.contentView.addSubview(view)
        return view
    }()
    
    private(set) lazy var fieldView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.isScrollEnabled = false
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.keyboardDismissMode = .interactive
        self.contentView.addSubview(view)
        return view
    }()

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelFit = size.insetBy(labelInset).infiniteHeight()
        let labelSize = labelView.sizeThatFits(labelFit).outsetBy(labelInset)

        let fieldFit = size.insetBy(fieldInset).infiniteHeight()
        let fieldSize = fieldView.sizeThatFits(fieldFit).outsetBy(fieldInset)

        return CGSize(width: max(labelSize.width, fieldSize.width), height: labelSize.height + fieldSize.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func textViewDidChange(_ textView: UITextView) {
        let startSize = fieldView.bounds.size
        let newSize = fieldView.sizeThatFits(CGSize(width: startSize.width, height: .greatestFiniteMagnitude))
        if startSize.height != newSize.height {
            didUpdate?()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fieldView.text = nil
    }
}
