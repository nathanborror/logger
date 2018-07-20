import Foundation

public struct KitError: Error {
    public enum Kind {
        case noResults
    }
    let kind: Kind
    let message: String

    init(_ kind: Kind, _ message: String) {
        self.kind = kind
        self.message = message
    }
}

public struct State: Codable, Equatable {
    public var entries: [Int: Entry]
    public var timeline: Timeline
    public var search: Search
    public var undo: Undo
}

public struct Timeline: Codable, Equatable {
    public var days: [Date: Day]
    public var lastUpdated: Date

    public struct Day: Codable, Equatable {
        public var date: Date
        public var entries: [Int]
    }
}

public struct Search: Codable, Equatable {
    public var query: String?
    public var results: [Int]
}

public struct Undo: Codable, Equatable {
    public var deleted: [Entry]
}

public struct Entry: Codable, Equatable, Hashable {
    public var id: Int
    public var kind: EntryKind
    public var alignment: EntryAlignment
    public var text: String
    public var image: URL?
    public var color: Int
    public var created: Date
    public var modified: Date

    public var hashValue: Int {
        return id.hashValue
    }
}

public enum EntryKind: Int, Codable {
    case text
    case image
}

public enum EntryAlignment: Int, Codable {
    case left
    case right
    case center
}
