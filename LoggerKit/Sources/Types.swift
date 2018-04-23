import Foundation

public struct State {
    public var entries: [Int: Entry]
    public var timeline: Timeline
    public var search: Search
}

public struct Timeline: Equatable {
    public var days: [Date: Day]
    public var lastUpdated: Date

    public struct Day: Equatable {
        public var date: Date
        public var entries: [Int]
    }
}

public struct Search: Equatable {
    public var query: String?
    public var results: [Int]
}

public struct Entry: Equatable, Hashable {
    public var id: Int
    public var text: String
    public var image: URL?
    public var color: Int
    public var created: Date
    public var modified: Date

    public var hashValue: Int {
        return id.hashValue
    }
}
