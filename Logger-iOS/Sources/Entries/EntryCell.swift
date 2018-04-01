import UIKit
import LoggerKit

class EntryCell: UITableViewCell {

    var contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    var onHashtagTap: ((String) -> Void)?
    var onLinkTap: ((URL) -> Void)?

    private let additionalHeight: CGFloat = 2 // TODO: Figure out why ActiveLabel needs this
    private let gapHeight: CGFloat = 2
    
    lazy var entryView: UILabel = {
        let view = ActiveLabel()
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .entryText
        view.numberOfLines = 0
        view.hashtagColor = .entryTint
        view.URLColor = .entryTint
        view.enabledTypes = [.url, .hashtag]
        view.handleURLTap { [weak self] url in
            self?.onLinkTap?(url)
        }
        view.handleHashtagTap { [weak self] tag in
            self?.onHashtagTap?(tag)
        }
        view.backgroundColor = .entryBackground
        view.tintColor = .entryTint
        self.contentView.addSubview(view)
        return view
    }()

    func configure(with entry: Entry) {
        entryView.text = entry.text
        contentView.backgroundColor = .entryBackground
        contentView.layer.cornerRadius = 19
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let insets = separatorInset + contentInset
        let entryFit = size.insetBy(insets).infiniteHeight()
        let entrySize = entryView.sizeThatFits(entryFit)
        return entrySize.outsetBy(insets) + CGSize(width: 0, height: gapHeight + additionalHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let insets = separatorInset + contentInset

        let entryFit = contentView.bounds.size.insetBy(insets)
        let entrySize = entryView.sizeThatFits(entryFit) + CGSize(width: 0, height: gapHeight)
        entryView.frame = CGRect(origin: contentInset.origin, size: entrySize)

        let contentSize = entrySize.outsetBy(contentInset)
        contentView.frame = CGRect(origin: separatorInset.origin, size: contentSize)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        entryView.text = nil
    }
}
