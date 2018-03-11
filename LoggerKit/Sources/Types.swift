import Foundation

public struct State {
    public var entries: [UUID: Entry]
    public var timeline: Timeline
}

public struct Timeline {
    public var days: [Date: Day]
    public var lastUpdated: Date

    public struct Day {
        public var date: Date
        public var entries: [UUID]
    }
}

public struct Entry {
    public var id: UUID
    public var text: String
    public var color: Int
    public var created: Date
    public var modified: Date
}

extension Entry: Equatable, Hashable {

    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Entry, rhs: Entry) -> Bool {
        return lhs.id == rhs.id &&
            lhs.text == rhs.text &&
            lhs.created == rhs.created &&
            lhs.modified == rhs.modified
    }
}
