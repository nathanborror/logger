import Foundation
import SQLite

class Store {

    internal let db: Connection

    init(url: URL) throws {
        print("💾 \(url.path)")
        self.db = try Connection(url.absoluteString)
        try setupDatabase()
    }
    
    func setupDatabase() throws {
        let tables: [String] = [
            """
            CREATE TABLE IF NOT EXISTS entry (
                id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
                text text NOT NULL,
                color integer NOT NULL,
                created integer NOT NULL,
                modified integer NOT NULL
            );
            """,
            """
            CREATE VIRTUAL TABLE IF NOT EXISTS entry_index USING fts5(text, tokenize=porter);
            """,
            """
            CREATE TRIGGER IF NOT EXISTS after_entry_insert AFTER INSERT ON entry BEGIN
                INSERT INTO entry_index (rowid, text) VALUES (new.id, new.text);
            END;
            """,
            """
            CREATE TRIGGER IF NOT EXISTS after_entry_update AFTER UPDATE OF text ON entry BEGIN
                UPDATE entry_index SET text = new.text WHERE rowid = old.id;
            END;
            """,
            """
            CREATE TRIGGER IF NOT EXISTS after_entry_insert AFTER DELETE ON entry BEGIN
                DELETE FROM entry_index WHERE rowid = old.id;
            END;
            """,
        ]
        for table in tables {
            let statement = try db.prepare(table)
            try statement.run()
        }
    }

    func entries() throws -> EntriesResponse {
        var results: [Entry] = []
        let select = "SELECT id, text, color, created, modified FROM entry;"
        for row in try db.prepare(select) {
            results.append(Entry(row: row))
        }
        return EntriesResponse(entries: results)
    }

    func entry(id: Int) throws -> Entry {
        var results: [Entry] = []
        let select = """
            SELECT id, text, color, created, modified
            FROM entry WHERE id = ?;
            """
        for row in try db.prepare(select).bind(id) {
            results.append(Entry(row: row))
        }
        guard let entry = results.first else {
            throw StoreError.missing("Entry for id '\(id)' not found")
        }
        return entry
    }

    func insert(entry rec: Entry) throws -> Entry {
        let insert = """
            INSERT INTO entry (text, color, created, modified)
            VALUES (?, ?, ?, ?);
            """
        let prepared = try db.prepare(insert)
        try prepared.run(rec.text, rec.color, rec.created, rec.modified)
        guard db.changes == 1 else {
            throw StoreError.failure("Failed to insert entry")
        }
        return try entry(id: Int(db.lastInsertRowid))
    }

    func update(entry rec: Entry, id: Int) throws -> Entry {
        let update = "UPDATE entry SET text=?, color=?, modified=? WHERE id=?;"
        let prepared = try db.prepare(update)
        try prepared.run(rec.text, rec.color, rec.modified, id)
        guard db.changes == 1 else {
            throw StoreError.failure("Failed to update entry")
        }
        return try entry(id: id)
    }

    func restore(entry rec: Entry) throws -> Entry {
        let insert = """
            INSERT INTO entry (text, color, created, modified)
            VALUES (?, ?, ?, ?);
            """
        let prepared = try db.prepare(insert)
        try prepared.run(rec.text, rec.color, rec.created, rec.modified)
        guard db.changes == 1 else {
            throw StoreError.failure("Failed to insert entry")
        }
        return try entry(id: Int(db.lastInsertRowid))
    }

    func delete(entry id: Int) throws {
        let delete = "DELETE FROM entry WHERE id = ?"
        let prepared = try db.prepare(delete)
        try prepared.run(id)
        guard db.changes == 1 else {
            throw StoreError.failure("Failed to delete entry")
        }
    }

    func search(entries query: String) throws -> [Int] {
        var results: [Int?] = []
        let select = "SELECT rowid FROM entry_index WHERE entry_index MATCH 'text:\(query) * ';"
        for row in try db.prepare(select) {
            results.append(encodeInt(row[0]))
        }
        return results.compactMap { $0 }
    }
}

enum StoreError: Error {
    case missing(String)
    case failure(String)
}

extension Store {

    struct Entry {
        var id: Int
        var text: String
        var color: Int
        var created: Int
        var modified: Int
    }

    struct EntriesResponse {
        let entries: [Entry]
    }
}

extension Store.Entry {

    init(row: Statement.Element) {
        self.id         = encodeInt(row[0])!
        self.text       = row[1] as! String
        self.color      = encodeInt(row[2])!
        self.created    = encodeInt(row[3])!
        self.modified   = encodeInt(row[4])!
    }

    init(id: Int = 0, text: String, color: Int = 0,
         modified: Int = Date.unixEpoch, created: Int = Date.unixEpoch) {
        self.id = id
        self.text = text
        self.color = color
        self.created = created
        self.modified = modified
    }
}

private func encodeInt(_ value: Binding?) -> Int? {
    guard let value = value as? Int64 else { return nil }
    return Int(value)
}
