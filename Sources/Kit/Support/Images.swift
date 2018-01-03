/// This is a generated file, do not edit

#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
    public typealias NativeColor = UIColor
    public typealias NativeImage = UIImage
#elseif os(OSX)
    import Cocoa
    public typealias NativeColor = NSColor
    public typealias NativeImage = NSImage
#endif

public protocol ImagesTargetable: AnyObject {
    func imageLoaded(result: ImagesResult)
}

public enum ImagesResult {
    case image(NativeImage)
    case error(ImagesError)

    public func onImage(_ handler: (NativeImage) -> ()) {
        if case .image(let i) = self { handler(i) }
    }
    public func onError(_ handler: (ImagesError) -> ()) {
        if case .error(let e) = self { handler(e) }
    }
    public var image: NativeImage? {
        if case .image(let i) = self { return i }
        return nil
    }
    public var error: ImagesError? {
        if case .error(let e) = self { return e }
        return nil
    }
}

public typealias ImagesResultCallback = (ImagesResult) -> ()

public enum ImagesError: Error {
    case imageNotFound
    case imageMalformed
    case networkFailure(underlying: Error?)
    case requestBad(exp: String)
    case unknown
}

public class Images {

    private var loads: [Load] = []
    private var cache: NSCache<NSString, NativeImage>

    public init() {
        self.cache = NSCache<NSString, NativeImage>()
    }

    public func load(from imageURL: URL?, size: CGSize? = nil, then: @escaping ImagesResultCallback) {
        assert(Thread.isMainThread)

        // URL can be passed nil for easy clearing of views
        guard let imageURL = imageURL else {
            then(.error(.imageNotFound))
            return
        }

        // Find or Create Load
        let load = findOrStartLoad(url: imageURL, size: size)
        load.attach(callback: then)

        // Run Load
        run(load)
    }

    public func load(from imageURL: URL?, size: CGSize? = nil, into target: ImagesTargetable) {
        assert(Thread.isMainThread)

        // Cancel any previous loads for target
        removeFromAnyLoad(target: target)

        // URL can be passed nil for easy clearing of views
        guard let imageURL = imageURL else {
            target.imageLoaded(result: .error(.imageNotFound))
            return
        }

        // Find or Create Load
        let load = findOrStartLoad(url: imageURL, size: size)
        load.attach(target: target)

        // Run Load
        run(load)
    }

    private func run(_ load: Load) {
        assert(Thread.isMainThread)

        // Wait for network task if already in progress
        if load.task != nil { return }

        // Attempt synchronous cached load
        let cacheKey = Images.cacheKeyFor(url: load.url, size: load.size)
        if let image = cache.object(forKey: cacheKey) {
            self.complete(load: load, with: image)
            return
        }

        // Resize from cached full size if available
        let fullSizeCacheKey = Images.cacheKeyFor(url: load.url, size: nil)
        if let size = load.size, let fullSizeImage = cache.object(forKey: fullSizeCacheKey) {
            resize(image: fullSizeImage, to: size, for: load)
            return
        }

        // Start Network Task
        load.task = URLSession.shared.dataTask(with: load.url) { data, response, error in

            // Check Network Errors
            guard let data = data, let _ = response, error == nil else {
                self.fail(load: load, error: .networkFailure(underlying: error))
                return
            }
            // Decode Data to Image
            guard var image = NativeImage(data: data) else {
                self.fail(load: load, error: .imageMalformed)
                return
            }
            // Resize if requested
            if let size = load.size {
                guard let resized = image.cgImage?.resizing(aspectFit: size) else {
                    self.fail(load: load, error: .imageMalformed)
                    return
                }
                image = NativeImage(cgImage: resized)
            }
            // Cache and Handle
            self.cache.setObject(image, forKey: cacheKey)
            self.complete(load: load, with: image)
        }
        load.task?.resume()
    }

    private func resize(image: NativeImage, to size: CGSize, for load: Load) {
        assert(Thread.isMainThread)

        // Async Run Resizer
        DispatchQueue.global(qos: .utility).async {
            guard let resized = image.cgImage?.resizing(aspectFit: size) else {
                self.fail(load: load, error: .imageMalformed)
                return
            }
            // Cache and Handle
            let image = NativeImage(cgImage: resized)
            let cacheKey = Images.cacheKeyFor(url: load.url, size: size)
            self.cache.setObject(image, forKey: cacheKey)
            self.complete(load: load, with: image)
        }
    }

    private func findOrStartLoad(url: URL, size: CGSize?) -> Load {
        assert(Thread.isMainThread)

        // URL and CGSize are unique per Load
        let found = loads.first {
            $0.url == url && $0.size == size
        }
        if let load = found {
            return load
        }
        // Add Load to active list
        let newLoad = Load(url: url, size: size)
        loads.append(newLoad)
        return newLoad
    }

    private func complete(load: Load, with image: NativeImage) {
        Images.executeOnMainThreadASAP {
            // Remove load from active list
            self.loads = self.loads.filter{ $0 !== load }

            // Notify concerned listeners
            load.targets.forEach{ $0.target?.imageLoaded(result: .image(image)) }
            load.callbacks.forEach{ $0(.image(image)) }
        }
    }

    private func fail(load: Load, error: ImagesError) {
        Images.executeOnMainThreadASAP {
            // Remove load from active list
            self.loads = self.loads.filter{ $0 !== load }

            // Notify concerned listeners
            load.targets.forEach{ $0.target?.imageLoaded(result: .error(error)) }
            load.callbacks.forEach{ $0(.error(error)) }
        }
    }

    private func removeFromAnyLoad(target: ImagesTargetable) {
        assert(Thread.isMainThread)

        // Remove Target from Any Load that has it
        loads.forEach { $0.detach(target: target) }

        // Cancel loads that no longer have targets or callbacks
        // Maybe this should be deferred to main thread async so ongoing downloads could get reattached to?
        self.loads = self.loads.filter {
            if $0.callbacks.count == 0 && $0.targets.count == 0 {
                $0.task?.cancel()
                return false
            }
            return true
        }
    }

    private static func executeOnMainThreadASAP(block: @escaping () -> Void) {
        if Thread.isMainThread { block(); return }
        DispatchQueue.main.async(execute: block)
    }

    private static func cacheKeyFor(url: URL, size: CGSize?) -> NSString {
        guard let size = size else { return url.absoluteString as NSString }
        return "\(size.width)x\(size.height):\(url.absoluteString)" as NSString
    }

    private class Load {
        let url: URL
        let size: CGSize?
        var task: URLSessionDataTask?
        var targets: [Target] = []
        var callbacks: [ImagesResultCallback] = []

        init(url: URL, size: CGSize?) {
            self.url = url
            self.size = size
        }

        func attach(target: ImagesTargetable) {
            targets.append(Target(target: target))
        }

        func attach(callback: @escaping ImagesResultCallback) {
            callbacks.append(callback)
        }

        func detach(target: ImagesTargetable) {
            targets = targets.filter {
                $0.target !== target
            }
        }
    }

    private struct Target {
        weak var target: ImagesTargetable?
    }
}


