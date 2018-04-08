import UIKit
import LoggerKit

class EntryCell: UITableViewCell {

    var imageSize = CGSize(width: 240, height: 180)
    var contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    var onHashtagTap: ((String) -> Void)?
    var onLinkTap: ((URL) -> Void)?

    private let additionalHeight: CGFloat = 2 // TODO: Figure out why ActiveLabel needs this
    private let gapHeight: CGFloat = 2
    private var isImage = false
    
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

    lazy var entryPhoto: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .entryBackground
        view.layer.cornerRadius = 19
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        contentView.addSubview(view)
        return view
    }()

    func configure(with entry: Entry) {
        if let data = Kit.openEntry(entry) {
            contentView.backgroundColor = .clear
            contentView.layer.cornerRadius = 0
            entryPhoto.image = UIImage(data: data)
            entryPhoto.isHidden = false
            entryView.isHidden = true
            isImage = true
        } else {
            contentView.backgroundColor = .entryBackground
            contentView.layer.cornerRadius = 19
            entryPhoto.isHidden = true
            entryView.isHidden = false
            entryView.text = entry.text
            isImage = false
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard isImage == false else {
            return imageSize
        }
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

        if isImage {
            entryPhoto.frame = CGRect(origin: .zero, size: imageSize)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        entryView.text = nil
        entryView.isHidden = false
        entryPhoto.isHidden = true
        entryPhoto.image = nil
        isImage = false
    }
}
