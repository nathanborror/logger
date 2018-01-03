import UIKit

class TextViewCell: UITableViewCell, UITextViewDelegate {
    
    var inset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    var onUrlTap: ((URL) -> Void)?
    
    private(set) lazy var textView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.isEditable = false
        view.isScrollEnabled = false
        self.contentView.addSubview(view)
        return view
    }()

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textFit = size.insetBy(inset).infiniteHeight()
        return textView.sizeThatFits(textFit).outsetBy(inset)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = bounds.insetBy(inset)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        onUrlTap?(url)
        return false
    }
}
