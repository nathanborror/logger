import UIKit
import LoggerKit

class EntryCell: UITableViewCell {

    var contentInset = UIEdgeInsets(top: 1, left: 8, bottom: 0, right: 32)
    var entryInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

    private lazy var entryLabel: UILabel = {
        let view = UILabel()
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .white
        view.numberOfLines = 0
        self.contentView.addSubview(view)
        return view
    }()

    func configure(with entry: Entry) {
        self.selectionStyle = .none
        self.entryLabel.text = entry.text
        self.contentView.backgroundColor = .black
        self.contentView.layer.cornerRadius = 18
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let entryFit = size.insetBy(contentInset + entryInset).infiniteHeight()
        let entrySize = entryLabel.sizeThatFits(entryFit)
        return entrySize.outsetBy(contentInset + entryInset)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let entryFit = bounds.size.insetBy(entryInset + contentInset)
        let entrySize = entryLabel.sizeThatFits(entryFit)
        var contentSize = contentView.bounds.insetBy(contentInset).size
        contentSize.width = entrySize.width + entryInset.left + entryInset.right

        entryLabel.frame = CGRect(origin: entryInset.origin, size: entrySize)
        contentView.frame = CGRect(origin: contentInset.origin, size: contentSize)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        entryLabel.text = nil
    }
}
