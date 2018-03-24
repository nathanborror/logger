import UIKit
import LoggerKit
import Attributed

class EntryCell: UITableViewCell {

    var contentInset = UIEdgeInsets(top: 1, left: 8, bottom: 0, right: 32)
    var entryInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    var onHashtagTap: ((String) -> Void)?
    var onLinkTap: ((String) -> Void)?

    lazy var entryView: AttributedTextView = {
        let view = AttributedTextView()
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .white
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.isScrollEnabled = false
        view.isEditable = false
        view.backgroundColor = .black
        view.tintColor = .lightGray
        self.contentView.addSubview(view)
        return view
    }()

    func configure(with entry: Entry) {
        self.selectionStyle = .none
        self.entryView.attributer = entry.text.white.size(17)
            .matchHashtags.lightGray.makeInteract { self.onHashtagTap?($0) }
            .matchLinks.lightGray.makeInteract { self.onLinkTap?($0) }
        self.contentView.backgroundColor = .black
        self.contentView.layer.cornerRadius = 18
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let entryFit = size.insetBy(contentInset + entryInset).infiniteHeight()
        let entrySize = entryView.sizeThatFits(entryFit)
        return entrySize.outsetBy(contentInset + entryInset)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let entryFit = bounds.size.insetBy(entryInset + contentInset)
        let entrySize = entryView.sizeThatFits(entryFit)
        var contentSize = contentView.bounds.insetBy(contentInset).size
        contentSize.width = entrySize.width + entryInset.left + entryInset.right

        entryView.frame = CGRect(origin: entryInset.origin, size: entrySize)
        contentView.frame = CGRect(origin: contentInset.origin, size: contentSize)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        entryView.text = nil
    }
}
