import Foundation

public struct State {
    public var entries: [Int: Entry]
    public var timeline: Timeline
    public var search: Search
    public var isCloudEnabled: Bool
}

public struct Timeline {
    public var days: [Date: Day]
    public var lastUpdated: Date

    public struct Day {
        public var date: Date
        public var entries: [Int]
    }
}

public struct Search {
    public var query: String?
    public var results: [Int]
}

public struct Entry {
    public var id: Int
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

extension Timeline: Equatable {
    public static func == (lhs: Timeline, rhs: Timeline) -> Bool {
        return lhs.days == rhs.days &&
            lhs.lastUpdated == rhs.lastUpdated
    }
}

extension Timeline.Day: Equatable {
    public static func == (lhs: Timeline.Day, rhs: Timeline.Day) -> Bool {
        return lhs.date == rhs.date &&
            lhs.entries == rhs.entries
    }
}

extension Search: Equatable {
    public static func == (lhs: Search, rhs: Search) -> Bool {
        return lhs.query == rhs.query &&
            lhs.results == rhs.results
    }
}
