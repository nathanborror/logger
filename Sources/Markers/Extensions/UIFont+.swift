import UIKit

extension UIFont {

    var bold: UIFont? {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return nil }
        return UIFont(descriptor: descriptor, size: pointSize)
    }

    var italic: UIFont? {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitItalic) else { return nil }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

