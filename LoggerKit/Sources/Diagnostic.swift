/// Diagnostic logs events and notifies subscribers of changes

#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

public class Diagnostic {

    public struct ImageInfo {
        public var perImageCounts = [URL:LoadCounts]()
        public var cumulativeCounts = LoadCounts()
        public var cacheHitRate: CGFloat = 0
        public var bytesDownloaded: Int = 0

        public struct LoadCounts {
            public var requestCount: Int = 0
            public var cancelCount: Int = 0
            public var downloadCount: Int = 0
            public var resizeCount: Int = 0
            public var cacheHitCount: Int = 0
            public var completeCount: Int = 0
            public var failCount: Int = 0
        }
    }

    internal enum ImageEvent {
        case requested(source: URL, size: CGSize?, time: Date)
        case cancelled(source: URL, size: CGSize?, time: Date)
        case downloaded(source: URL, size: CGSize?, time: Date, bytes: Int)
        case resized(source: URL, size: CGSize?, time: Date)
        case completed(source: URL, size: CGSize?, time: Date, isFromCache: Bool)
        case failed(source: URL, size: CGSize?, time: Date, error: Error)
    }

    public var imageInfo: ImageInfo { return assembleImageInfo() }

    private var _imageEvents = [ImageEvent]()
    private var _imageEventQueue = DispatchQueue(label: "ImageEventWork")
    private var _imageInfo: ImageInfo?

    internal func insert(imageEvent: ImageEvent) {
        _imageEventQueue.sync {
            _imageEvents.append(imageEvent)
            _imageInfo = nil
        }
    }

    private func assembleImageInfo() -> ImageInfo {
        return _imageEventQueue.sync {
            if let cached = _imageInfo { return cached }

            var imageInfo = ImageInfo()
            let deflc = ImageInfo.LoadCounts()
            for idx in 0..<_imageEvents.count {
                switch _imageEvents[idx] {
                case let .requested(source, _, _):
                    imageInfo.perImageCounts[source, default: deflc].requestCount += 1
                    imageInfo.cumulativeCounts.requestCount += 1
                case let .cancelled(source, _, _):
                    imageInfo.perImageCounts[source, default: deflc].cancelCount += 1
                    imageInfo.cumulativeCounts.cancelCount += 1
                case let .downloaded(source, _, _, bytes):
                    imageInfo.perImageCounts[source, default: deflc].downloadCount += 1
                    imageInfo.cumulativeCounts.downloadCount += 1
                    imageInfo.bytesDownloaded += bytes
                case let .resized(source, _, _):
                    imageInfo.perImageCounts[source, default: deflc].resizeCount += 1
                    imageInfo.cumulativeCounts.resizeCount += 1
                case let .completed(source, _, _, isFromCache):
                    imageInfo.perImageCounts[source, default: deflc].completeCount += 1
                    imageInfo.perImageCounts[source, default: deflc].cacheHitCount += isFromCache ? 1 : 0
                    imageInfo.cumulativeCounts.completeCount += 1
                    imageInfo.cumulativeCounts.cacheHitCount += isFromCache ? 1 : 0
                case let .failed(source, _, _, _):
                    imageInfo.perImageCounts[source, default: deflc].failCount += 1
                    imageInfo.cumulativeCounts.failCount += 1
                }
            }
            let c = imageInfo.cumulativeCounts
            imageInfo.cacheHitRate = CGFloat(c.cacheHitCount) / CGFloat(c.requestCount)
            return imageInfo
        }
    }
}


