import UIKit

extension UIFont {
    static let title = UIFont.preferredFont(forTextStyle: .title1)
    static let regular = UIFont.preferredFont(forTextStyle: .body)
    static let timestamp = UIFont.preferredFont(forTextStyle: .footnote)
    static let label = UIFont.preferredFont(forTextStyle: .title2)
}

extension UIColor {
    
    static let entryBackground = UIColor(hex: 0x000000)
    static let entryText = UIColor(hex: 0xFFFFFF)
    static let entryTint = UIColor(hex: 0xFFFF7F)
}

extension UIImage {

    static let iconSearch = UIImage(named: "Search")!.withRenderingMode(.alwaysTemplate)
}
