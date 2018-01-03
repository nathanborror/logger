import Foundation

public struct KitError: Error, Codable {
    public let message: String
    public var localizedDescription: String { return message }
}

extension KitError {

    init(_ message: String) {
        self.message = message
    }
}

extension KitError: Equatable {
    public static func ==(lhs: KitError, rhs: KitError) -> Bool {
        return lhs.message == rhs.message
    }
}
