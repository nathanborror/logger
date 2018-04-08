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

    public static func entryCreate(text: String, color: Int? = nil) throws {
        var entry = Store.Entry(text: text)
        entry = try store.insert(entry: entry)
        commit { $0.apply(entry: entry) }
    }

    public static func entryCreate(url: URL) throws {
        let filename = "\(Date.since1970).\(url.pathExtension)"
        var newURL = defaultPhotosURL
        newURL.appendPathComponent(filename)
        try FileManager.default.copyItem(at: url, to: newURL)
        try entryCreate(text: "![image](\(filename))")
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
    
    public static func entryDelete(entry: Entry) throws {
        try store.delete(entry: entry.id)
        commit { $0.entries.removeValue(forKey: entry.id) }

        if let imageURL = imageURL(for: entry) {
            try FileManager.default.removeItem(at: imageURL)
        }
    }

    public static func entrySearch(_ query: String?) throws {
        if query == nil || query?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            commit { $0.search.apply(entries: [], for: nil) }
            return
        }
        let ids = try store.search(entries: query!)
        commit { $0.search.apply(entries: ids, for: query) }
    }

    public static func openEntry(_ entry: Entry) -> Data? {
        if let imageURL = imageURL(for: entry) {
            return try? Data(contentsOf: imageURL)
        }
        return nil
    }

    private static func imageURL(for entry: Entry) -> URL? {
        if let image = entry.text.match(regex: "^(!\\[image\\])\\(\\d+.(jpeg|png|jpg)\\)$").first {
            let filename = String(image.dropFirst(9).dropLast(1))
            var url = defaultPhotosURL
            url.appendPathComponent(filename)
            return url
        }
        return nil
    }
}
