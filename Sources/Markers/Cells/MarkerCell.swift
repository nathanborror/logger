import UIKit
import Kit

class MarkerCell: UITableViewCell {

    var identifier: UUID?

    var contentInset = UIEdgeInsets(top: 1, left: 8, bottom: 0, right: 32)
    var markerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

    private lazy var markerLabel: UILabel = {
        let view = UILabel()
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .white
        view.numberOfLines = 0
        self.contentView.addSubview(view)
        return view
    }()

    func configure(with marker: Marker) {
        self.identifier = marker.id
        self.markerLabel.text = marker.text
        self.contentView.backgroundColor = .black
        self.contentView.layer.cornerRadius = 18
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let markerFit = size.insetBy(contentInset + markerInset).infiniteHeight()
        let markerSize = markerLabel.sizeThatFits(markerFit)
        return markerSize.outsetBy(contentInset + markerInset)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let markerFit = bounds.size.insetBy(markerInset + contentInset)
        let markerSize = markerLabel.sizeThatFits(markerFit)
        var contentSize = contentView.bounds.insetBy(contentInset).size
        contentSize.width = markerSize.width + markerInset.left + markerInset.right

        markerLabel.frame = CGRect(origin: markerInset.origin, size: markerSize)
        contentView.frame = CGRect(origin: contentInset.origin, size: contentSize)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        markerLabel.text = nil
    }
}
