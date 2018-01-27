import Foundation

public struct State: Codable {
    public var markers: [UUID: Marker]
    public var error: KitError?
}

public struct Marker: Codable {
    public var id: UUID
    public var text: String
    public var color: Int
    public var created: Date
    public var modified: Date
    public var error: KitError?
}

extension Marker: Equatable, Hashable {

    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Marker, rhs: Marker) -> Bool {
        return lhs.id == rhs.id &&
            lhs.text == rhs.text &&
            lhs.created == rhs.created &&
            lhs.modified == rhs.modified &&
            lhs.error == rhs.error
    }
}
