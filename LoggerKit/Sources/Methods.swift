import Foundation

extension Kit {

    public static func activate() throws {
        let entries = try store.entries()
        commit("activate") {
            $0.apply(entries: entries.entries)
            $0.timeline.apply(entries: entries.entries)
        }
    }

    public static func suspend() throws {
    }

    public static func undoEntryDelete() throws {
        guard let entry = state.undo.deleted.last else {
            return
        }
        commit("entry:undo") { $0.undo.deleted.removeLast() }
        try entryRestore(entry: entry)
    }

    public static func entryCreate(text: String, color: Int? = nil) throws {
        var entry = Store.Entry(text: text)
        entry = try store.insert(entry: entry)
        commit("entry:create") { $0.apply(entry: entry) }
    }

    public static func entryCreate(url: URL) throws {
        let filename = "\(Date.unixEpoch).\(url.pathExtension)"
        var newURL = FileManager.photosDir
        newURL.appendPathComponent(filename)
        try FileManager.default.copyItem(at: url, to: newURL)
        try entryCreate(text: "![image](\(filename))")
    }

    public static func entryRestore(entry: Entry) throws {

        // Recover entry
        let storeEntry = Store.Entry(id: entry.id, text: entry.text, color: entry.color,
                                created: entry.created.unixEpoch,
                                modified: entry.modified.unixEpoch)
        let restored = try store.restore(entry: storeEntry)

        // Recover entry image
        if let tempURL = entry.image, let imageURL = decodeImageURL(entry.text) {
            try FileManager.default.moveItem(at: tempURL, to: imageURL)
        }
        commit("entry:restore") { $0.apply(entry: restored) }
    }

    public static func entry(_ id: Int, setText text: String) throws {
        var entry = try store.entry(id: id)
        entry.text = text
        entry = try store.update(entry: entry, id: id)
        commit("entry:set:text") { $0.apply(entry: entry) }
    }

    public static func entry(_ id: Int, setColor color: Int) throws {
        var entry = try store.entry(id: id)
        entry.color = color
        entry = try store.update(entry: entry, id: id)
        commit("entry:set:color") { $0.apply(entry: entry) }
    }
    
    public static func entryDelete(entry: Entry) throws {
        var entry = entry
        if let imageURL = entry.image {
            var tempURL = FileManager.photosCacheDir
            tempURL.appendPathComponent(imageURL.lastPathComponent)
            try FileManager.default.moveItem(at: imageURL, to: tempURL)
            entry.image = tempURL
        }
        try store.delete(entry: entry.id)
        commit("entry:delete") {
            $0.entries.removeValue(forKey: entry.id)
            $0.undo.deleted.append(entry)
        }
    }

    public static func entrySearch(_ query: String?) throws {
        if query == nil || query?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            commit("entry:search") { $0.search.apply(entries: [], for: nil) }
            return
        }
        let ids = try store.search(entries: query!)
        commit("entry:search") { $0.search.apply(entries: ids, for: query) }
    }
}
