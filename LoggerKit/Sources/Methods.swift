import Foundation

extension Kit {

    public static func activate() throws {
        let entries = try store.entries()
        commit {
            $0.apply(entries: entries.entries)
            $0.timeline.apply(entries: entries.entries)
        }
    }

    public static func suspend() throws {
    }

    public static func entryCreate(_ text: String, color: Int? = nil) throws {
        var entry = Store.Entry(text: text)
        entry = try store.insert(entry: entry)
        commit { $0.apply(entry: entry) }
    }

    public static func entry(_ id: Int, setText text: String) throws {
        var entry = try store.entry(id: id)
        entry.text = text
        entry = try store.update(entry: entry, id: id)
        commit { $0.apply(entry: entry) }
    }

    public static func entry(_ id: Int, setColor color: Int) throws {
        var entry = try store.entry(id: id)
        entry.color = color
        entry = try store.update(entry: entry, id: id)
        commit { $0.apply(entry: entry) }
    }
    
    public static func entryDelete(entry id: Int) throws {
        try store.delete(entry: id)
        commit { $0.entries.removeValue(forKey: id) }
    }

    public static func entrySearch(_ query: String?) throws {
        if query == nil || query?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            commit { $0.search.apply(entries: [], for: nil) }
            return
        }
        let ids = try store.search(entries: query!)
        commit { $0.search.apply(entries: ids, for: query) }
    }
}
