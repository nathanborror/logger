import Foundation

extension DispatchQueue {

    private static let mainQueueTagKey = DispatchSpecificKey<UInt8>()
    private static let mainQueueTagValue: UInt8 = 42

    private static var isMainQueueTagged: Bool = {
        DispatchQueue.main.setSpecific(key: mainQueueTagKey, value: mainQueueTagValue)
        return true
    }()

    static var isMainQueue: Bool {
        let _ = DispatchQueue.isMainQueueTagged // Lazily tag main queue
        return DispatchQueue.main.getSpecific(key: DispatchQueue.mainQueueTagKey) == DispatchQueue.mainQueueTagValue
    }
}

