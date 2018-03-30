import UIKit
import LoggerKit

class EntryCell: UITableViewCell {

    var contentInset = UIEdgeInsets(top: 1, left: 8, bottom: 0, right: 32)
    var entryInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    var onHashtagTap: ((String) -> Void)?
    var onLinkTap: ((URL) -> Void)?
    
    lazy var entryView: UILabel = {
        let view = ActiveLabel()
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .entryText
        view.hashtagColor = .entryTint
        view.URLColor = .entryTint
        view.numberOfLines = 0
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
        contentView.layer.cornerRadius = 18
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
