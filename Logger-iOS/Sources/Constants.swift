import UIKit

extension UIFont {
    static let title = UIFont.preferredFont(forTextStyle: .title1)
    static let regular = UIFont.preferredFont(forTextStyle: .body)
    static let timestamp = UIFont.preferredFont(forTextStyle: .footnote)
    static let label = UIFont.preferredFont(forTextStyle: .title2)
}

extension UIColor {
    
    static let tint = #colorLiteral(red: 0.01169153582, green: 0.4773681164, blue: 1, alpha: 1)
    static let foreground = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let warning = #colorLiteral(red: 1, green: 0.4436733723, blue: 0.464625299, alpha: 1)
    static let background = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
}

extension UIImage {

    static let iconSearch = UIImage(named: "Search")!.withRenderingMode(.alwaysTemplate)
}
