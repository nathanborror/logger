import UIKit

extension UIEdgeInsets {

    /// Returns the sum left and right insets.
    var totalHorizontal: CGFloat {
        return left + right
    }

    /// Returns the sum top and bottom insets.
    var totalVertical: CGFloat {
        return top + bottom
    }

    /// Returns a point based on the inset's top and left values.
    var origin: CGPoint {
        return CGPoint(x: left, y: top)
    }

    static func +(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
    }
}

extension CGSize {

    /// Returns a size inset by the given insets.
    func insetBy(_ inset: UIEdgeInsets) -> CGSize {
        return CGSize(width: width - inset.totalHorizontal, height: height - inset.totalVertical)
    }

    /// Returns a size with its height set to infinity.
    func infiniteHeight() -> CGSize {
        return CGSize(width: width, height: .greatestFiniteMagnitude)
    }

    /// Returns a size that adds the given insets.
    func outsetBy(_ inset: UIEdgeInsets) -> CGSize {
        return CGSize(width: width + inset.totalHorizontal, height: height + inset.totalVertical)
    }

    /// Returns a size that is the combined width and height.
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

extension CGRect {

    /// Returns a rect with the given insets subtracted from it's size while maintaining it's center point.
    func insetBy(_ inset: UIEdgeInsets) -> CGRect {
        return CGRect(x: minX + inset.left, y: minY + inset.top, width: width - inset.totalHorizontal, height: height - inset.totalVertical)
    }
}

extension CGPoint {

    func distance(_ b: CGPoint) -> CGFloat {
        return sqrt(pow(x - b.x, 2) + pow(y - b.y, 2))
    }

    /// Returns a CGPoint offset by the given CGRect's maxY position.
    func offsetY(_ rect: CGRect) -> CGPoint {
        return CGPoint(x: x, y: y + rect.maxY)
    }

    /// Returns a CGPoint offset by the given CGRect's maxX position.
    func offsetX(_ rect: CGRect) -> CGPoint {
        return CGPoint(x: x + rect.maxX, y: y)
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
}
