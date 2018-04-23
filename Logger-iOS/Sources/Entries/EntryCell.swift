import UIKit
import LoggerKit

class EntryCell: UITableViewCell {

    var imageSize = CGSize(width: 240, height: 180)
    var contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    var onHashtagTap: ((String) -> Void)?
    var onLinkTap: ((URL) -> Void)?
    var onEntryPhotoTap: ((UIImage) -> Void)?

    private let additionalHeight: CGFloat = 2 // TODO: Figure out why ActiveLabel needs this
    private let gapHeight: CGFloat = 1
    private var isImage = false
    private var entry: Entry? = nil { didSet { entryDidSet() }}
    
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
        contentView.addSubview(view)
        return view
    }()

    lazy var entryPhoto: UIButton = {
        let view = UIButton()
        view.backgroundColor = .entryBackground
        view.layer.cornerRadius = 19
        view.clipsToBounds = true
        view.imageView?.contentMode = .scaleAspectFill
        view.addTarget(self, action: #selector(handleEntryPhotoTap), for: .touchUpInside)
        contentView.addSubview(view)
        return view
    }()

    func configure(with entry: Entry) {
        backgroundColor = .background
        self.entry = entry
    }

    func entryDidSet() {
        guard let entry = entry else {
            entryView.text = nil
            entryView.isHidden = false
            entryPhoto.isHidden = true
            entryPhoto.setImage(nil, for: .normal)
            isImage = false
            return
        }
        if let imageURL = entry.image, let data = try? Data(contentsOf: imageURL) {
            contentView.backgroundColor = .clear
            contentView.layer.cornerRadius = 0
            entryPhoto.setImage(UIImage(data: data), for: .normal)
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

    @objc func handleEntryPhotoTap() {
        guard let image = entryPhoto.imageView?.image else { return }
        onEntryPhotoTap?(image)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard isImage == false else {
            return CGSize(width: imageSize.width, height: imageSize.height + additionalHeight)
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
        let entrySize = entryView.sizeThatFits(entryFit) + CGSize(width: 0, height: additionalHeight)
        entryView.frame = CGRect(origin: contentInset.origin, size: entrySize)

        let contentSize = entrySize.outsetBy(contentInset)
        contentView.frame = CGRect(origin: separatorInset.origin, size: contentSize)

        if isImage {
            entryPhoto.frame = CGRect(origin: .zero, size: imageSize)
            contentView.frame = CGRect(origin: separatorInset.origin, size: imageSize)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        entry = nil
    }
}
