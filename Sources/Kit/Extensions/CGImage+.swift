#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

extension CGImage {

    public static func blank(size: CGSize, color: CGColor) -> CGImage? {
        let height = size.height > 0 ? size.height : 1
        let width  = size.width  > 0 ? size.width  : 1
        let size   = CGSize(width: width, height: height)
        guard let ctx = CGImage.contextForDrawing(size: size) else {
            return nil
        }
        ctx.setFillColor(color)
        ctx.fill(CGRect(origin: .zero, size: size))
        return ctx.makeImage()
    }

    public static func tile(size: CGSize, cornerRadius: CGFloat, color: CGColor) -> CGImage? {
        let clearColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 0.0])!
        let path = CGImage.pathForTile(frame: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius)
        guard let ctx = CGImage.contextForDrawing(size: size) else {
            return nil
        }
        ctx.setFillColor(clearColor)
        ctx.fill(CGRect(origin: .zero, size: size))
        ctx.setFillColor(color)
        ctx.addPath(path)
        ctx.closePath()
        ctx.fillPath()
        return ctx.makeImage()
    }

    public static func tileBorder(size: CGSize, cornerRadius: CGFloat, from: CGColor, to: CGColor) -> CGImage? {
        let outerFrame = CGRect(origin: .zero, size: size)
        let innerFrame = outerFrame.insetBy(dx: 2, dy: 2)
        let outerPath = CGImage.pathForTile(frame: outerFrame, cornerRadius: cornerRadius)
        let innerPath = CGImage.pathForTile(frame: innerFrame, cornerRadius: cornerRadius - 2)
        guard let ctx = CGImage.contextForDrawing(size: size) else {
            return nil
        }
        let colors: [CGColor] = [from, to]
        let cs = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: cs, colors: colors as CFArray, locations: nil)
        let gradStart = CGPoint(x: outerFrame.midX, y: outerFrame.minY)
        let gradEnd = CGPoint(x: outerFrame.minX, y: outerFrame.maxX)
        let gradOptions: CGGradientDrawingOptions = [.drawsBeforeStartLocation]

        ctx.addPath(outerPath)
        ctx.addPath(innerPath)
        ctx.closePath()
        ctx.clip(using: .evenOdd)
        ctx.drawLinearGradient(gradient!, start: gradStart, end: gradEnd, options: gradOptions)
        ctx.resetClip()
        return ctx.makeImage()
    }

    public static func squircle(size: Int, squareness: CGFloat, color: CGColor) -> CGImage? {
        let size = max(size, 1)
        let imageSize = CGSize(width: size, height: size)
        let clearColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 0.0])!
        let path = CGImage.pathForSquircle(size: size, squareness: squareness)
        guard let ctx = CGImage.contextForDrawing(size: imageSize) else {
            return nil
        }
        ctx.setFillColor(clearColor)
        ctx.fill(CGRect(origin: .zero, size: imageSize))
        ctx.setFillColor(color)
        ctx.addPath(path)
        ctx.closePath()
        ctx.fillPath()
        return ctx.makeImage()
    }

    public func resizing(withinBox: CGSize) -> CGImage? {
        let size = CGSize(width: width, height: height)
        if size.width <= withinBox.width, size.height <= withinBox.height {
            return self
        }
        return resizing(aspectFit: withinBox)
    }

    public func resizing(aspectFit: CGSize) -> CGImage? {
        let size = CGSize(width: width, height: height)
        let fitSize = CGImage.sizeForAspectFit(ratio: size, box: aspectFit)
        guard let ctx = CGImage.contextForDrawing(size: fitSize) else {
            return nil
        }
        ctx.draw(self, in: CGRect(origin: .zero, size: fitSize))
        return ctx.makeImage()
    }

    public func resizing(aspectFill: CGSize) -> CGImage? {
        let size = CGSize(width: width, height: height)
        let fillSize = CGImage.sizeForAspectFill(ratio: size, box: aspectFill)
        guard let ctx = CGImage.contextForDrawing(size: aspectFill) else {
            return nil
        }
        ctx.draw(self, in: CGRect(origin: .zero, size: fillSize))
        return ctx.makeImage()
    }

    public func cropping(square: Int) -> CGImage? {
        let ownDimension = min(width, height)
        let boxDimension = min(ownDimension, square)
        return resizing(aspectFill: CGSize(width: boxDimension, height: boxDimension))
    }

    private static func sizeForAspectFit(ratio: CGSize, box: CGSize) -> CGSize {
        var fitSize = box
        let widthFactor = box.width / ratio.width;
        let heightFactor = box.height / ratio.height;
        if heightFactor < widthFactor {
            fitSize.width = heightFactor * ratio.width
        } else if heightFactor > widthFactor {
            fitSize.height = widthFactor * ratio.height
        }
        return fitSize
    }

    private static func sizeForAspectFill(ratio: CGSize, box: CGSize) -> CGSize {
        var fillSize = box
        let widthFactor = box.width / ratio.width;
        let heightFactor = box.height / ratio.height;
        if heightFactor > widthFactor {
            fillSize.width = heightFactor * ratio.width
        } else if heightFactor < widthFactor {
            fillSize.height = widthFactor * ratio.height
        }
        return fillSize
    }

    private static func pathForTile(frame: CGRect, cornerRadius: CGFloat) -> CGPath {
        let origin = frame.origin
        let size = frame.size
        let minDim = min(size.height, size.width)
        let halfSize = CGFloat(minDim)/2
        let bigRadius = halfSize * 0.9

        let topEdge       = CGFloat(origin.y + size.height)
        let rightEdge     = CGFloat(origin.x + size.width)
        let bottomEdge    = CGFloat(origin.y)
        let leftEdge      = CGFloat(origin.x)

        let topLeftPoint  = CGPoint(x: leftEdge + cornerRadius, y: topEdge)
        let topRightPoint = CGPoint(x: rightEdge - cornerRadius, y: topEdge)
        let rightTopPoint = CGPoint(x: rightEdge, y: topEdge - cornerRadius)
        let rightBottomPoint = CGPoint(x: rightEdge, y: bottomEdge + bigRadius)
        let bottomRightPoint = CGPoint(x: rightEdge - bigRadius, y: bottomEdge)
        let bottomLeftPoint = CGPoint(x: leftEdge + cornerRadius, y: bottomEdge)
        let leftBottomPoint = CGPoint(x: leftEdge, y: bottomEdge + cornerRadius)
        let leftTopPoint = CGPoint(x: leftEdge, y: topEdge - cornerRadius)

        let path = CGMutablePath()
        path.move(to: topLeftPoint)
        path.addLine(to: topRightPoint)
        path.addArc(tangent1End: CGPoint(x: rightEdge, y: topEdge),
                    tangent2End: rightTopPoint,
                    radius: cornerRadius)
        path.addLine(to: rightBottomPoint)
        path.addArc(tangent1End: CGPoint(x: rightEdge, y: bottomEdge),
                    tangent2End: bottomRightPoint,
                    radius: bigRadius)
        path.addLine(to: bottomLeftPoint)
        path.addArc(tangent1End: CGPoint(x: leftEdge, y: bottomEdge),
                    tangent2End: leftBottomPoint,
                    radius: cornerRadius)
        path.addLine(to: leftTopPoint)
        path.addArc(tangent1End: CGPoint(x: leftEdge, y: topEdge),
                    tangent2End: topLeftPoint,
                    radius: cornerRadius)
        path.closeSubpath()
        return path
    }

    private static func pathForSquircle(size: Int, squareness: CGFloat) -> CGPath {
        var squareness = squareness
        squareness = min(squareness, 1.0)
        squareness = max(squareness, 0.0)
        let halfSize = CGFloat(size)/2
        let offset = halfSize * squareness

        let topEdge       = CGFloat(0)
        let rightEdge     = CGFloat(size)
        let bottomEdge    = CGFloat(size)
        let leftEdge      = CGFloat(0)
        let topPoint      = CGPoint(x: halfSize, y: topEdge)
        let rightPoint    = CGPoint(x: rightEdge, y: halfSize)
        let bottomPoint   = CGPoint(x: halfSize, y: bottomEdge)
        let leftPoint     = CGPoint(x: leftEdge, y: halfSize)
        let controlTop    = halfSize - offset
        let controlRight  = halfSize + offset
        let controlBottom = halfSize + offset
        let controlLeft   = halfSize - offset

        let path = CGMutablePath()
        path.move(to: topPoint)
        path.addCurve(to: rightPoint,
                      control1: CGPoint(x: controlRight, y: topEdge),
                      control2: CGPoint(x: rightEdge, y: controlTop))
        path.addCurve(to: bottomPoint,
                      control1: CGPoint(x: rightEdge, y: controlBottom),
                      control2: CGPoint(x: controlRight, y: bottomEdge))
        path.addCurve(to: leftPoint,
                      control1: CGPoint(x: controlLeft, y: bottomEdge),
                      control2: CGPoint(x: leftEdge, y: controlBottom))
        path.addCurve(to: topPoint,
                      control1: CGPoint(x: leftEdge, y: controlTop),
                      control2: CGPoint(x: controlLeft, y: topEdge))
        path.closeSubpath()
        return path
    }

    private static func contextForDrawing(size: CGSize) -> CGContext? {
        let scale = CGImage.scaleForDrawing
        let ctx = CGContext(
            data: nil,
            width: Int(size.width) * scale,
            height: Int(size.height) * scale,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        ctx?.interpolationQuality = .high
        ctx?.scaleBy(x: CGFloat(scale), y: CGFloat(scale))
        return ctx
    }

    private static var scaleForDrawing: Int = {
        #if os(iOS) || os(tvOS)
            return Int(UIScreen.main.scale)
        #elseif os(watchOS)
            return WKInterfaceDevice.current().screenScale
        #elseif os(OSX)
            let maxScaleScreen = NSScreen.screens.max(by: { $0.backingScaleFactor < $1.backingScaleFactor })
            let maxScale = Int(maxScaleScreen?.backingScaleFactor ?? 1)
            return maxScale
        #endif
    }()
}


