import UIKit

class FormInputCell: UITableViewCell {
    
    var labelInset = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
    var fieldInset = UIEdgeInsets(top: 8, left: 16, bottom: 10, right: 16)
    var value: String? {
        return fieldView.text
    }
    
    private(set) lazy var labelView: UILabel = {
        let view = UILabel()
        self.contentView.addSubview(view)
        return view
    }()
    
    private(set) lazy var fieldView: UITextField = {
        let view = UITextField()
        view.clearButtonMode = .always
        self.contentView.addSubview(view)
        return view
    }()
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelFit = size.insetBy(labelInset).infiniteHeight()
        let labelSize = labelView.isHidden ? .zero : labelView.sizeThatFits(labelFit).outsetBy(labelInset)
        
        let fieldFit = size.insetBy(fieldInset).infiniteHeight()
        let fieldSize = fieldView.sizeThatFits(fieldFit).outsetBy(fieldInset)
        
        return CGSize(width: max(labelSize.width, fieldSize.width), height: labelSize.height + fieldSize.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelFit = bounds.size.insetBy(labelInset)
        let labelSize = labelView.sizeThatFits(labelFit)
        labelView.frame = labelView.isHidden ? .zero : CGRect(origin: labelInset.origin, size: labelSize)
        
        let fieldFit = bounds.size.insetBy(fieldInset)
        var fieldSize = fieldView.sizeThatFits(fieldFit)
        fieldSize.width = bounds.width - fieldInset.totalHorizontal
        fieldView.frame = CGRect(origin: fieldInset.origin.offsetY(labelView.frame), size: fieldSize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fieldView.text = nil
    }
}

