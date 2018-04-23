import UIKit

extension State {

    init() {
        self.entries = [:]
        self.timeline = Timeline()
        self.search = Search()
        self.undo = Undo()
    }

    mutating func apply(entries: [Store.Entry]) {
        self.entries.removeAll()
        for entry in entries {
            apply(entry: entry)
        }
    }

    mutating func apply(entry: Store.Entry) {
        if var existing = entries[entry.id] {
            existing.apply(store: entry)
            self.entries[existing.id] = existing
        } else {
            let newEntry = Entry(store: entry)
            self.entries[newEntry.id] = newEntry
        }
    }
}

extension Timeline {

    init() {
        self.days = [:]
        self.lastUpdated = Date()
    }

    mutating func apply(entries: [Store.Entry]) {
        let sorted = entries.sorted { $0.created > $1.created }
        var days: [Date: Day] = [:]
        for entry in sorted {
            let created = must(parseEpoch: entry.created)
            let date = created.truncate(to: [.year, .month, .day])
            if days[date] == nil {
                days[date] = Day(date: date, entries: [])
            }
            days[date]?.entries.append(entry.id)
        }
        self.days = days
        self.lastUpdated = Date()
    }
}

extension Search {

    init() {
        self.query = nil
        self.results = []
    }

    mutating func apply(entries: [Int], for query: String?) {
        self.query = query
        self.results = entries
    }
}

extension Undo {

    init() {
        self.deleted = []
    }
}

extension Entry {

    init(store: Store.Entry) {
        self.id = store.id
        self.text = store.text
        self.image = decodeImageURL(store.text)
        self.color = store.color
        self.created = must(parseEpoch: store.created)
        self.modified = must(parseEpoch: store.modified)
    }

    mutating func apply(store: Store.Entry) {
        self.text = store.text
        self.color = store.color
        self.modified = must(parseEpoch: store.modified, or: self.modified)
    }
}

func must(parseUUID value: String?, or: UUID = UUID()) -> UUID {
    guard let value = value, let uuid = UUID(uuidString: value) else { return or }
    return uuid
}

func must(parseEpoch value: Int?, or: Date = Date()) -> Date {
    guard let value = value, let interval = TimeInterval(exactly: value) else { return or }
    return Date(timeIntervalSince1970: interval)
}

func decodeImageURL(_ text: String) -> URL? {
    if let image = text.match(regex: "^(!\\[image\\])\\(\\d+.(jpeg|png|jpg)\\)$").first {
        let filename = String(image.dropFirst(9).dropLast(1))
        var url = defaultPhotosURL
        url.appendPathComponent(filename)
        return url
    }
    return nil
}

