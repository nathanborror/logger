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
    static let systemBlue = UIColor(hex: 0x327BF7)
}

extension UIImage {

    static let iconSearch = UIImage(named: "Search")!.withRenderingMode(.alwaysTemplate)
    static let iconClear = UIImage(named: "Clear")!.withRenderingMode(.alwaysTemplate)
    static let iconArrowUp = UIImage(named: "ArrowUp")!.withRenderingMode(.alwaysTemplate)
    static let iconCamera = UIImage(named: "Camera")!.withRenderingMode(.alwaysTemplate)
}
