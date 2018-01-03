import UIKit

class LabelCell: UITableViewCell {
    
    var inset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    private(set) lazy var labelView: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        self.contentView.addSubview(view)
        return view
    }()

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let contentSize = size.insetBy(inset).infiniteHeight()
        return labelView.sizeThatFits(contentSize).outsetBy(inset)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        labelView.frame = bounds.insetBy(inset)
    }
}
