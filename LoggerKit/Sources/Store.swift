import Foundation
import SQLite

class Store {

    internal let db: Connection

    init() throws {
        let dir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let file = dir.appendingPathComponent("logger.db")
        print("💾 \(file)")

        self.db = try Connection(file.absoluteString)

        let tables: [String] = [
            """
            CREATE TABLE IF NOT EXISTS entry (
                id text NOT NULL PRIMARY KEY,
                text text NOT NULL,
                color integer NOT NULL,
                created integer NOT NULL,
                modified integer NOT NULL
            );
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

    func entry(id: UUID) throws -> Entry {
        var results: [Entry] = []
        let select = """
            SELECT id, text, color, created, modified
            FROM entry WHERE id = ?;
            """
        for row in try db.prepare(select).bind(id.uuidString) {
            results.append(Entry(row: row))
        }
        guard let entry = results.first else {
            throw StoreError.missing("Entry for id '\(id)' not found")
        }
        return entry
    }

    func insert(entry rec: Entry) throws -> Entry {
        let insert = """
            INSERT INTO entry (id, text, color, created, modified)
            VALUES (?, ?, ?, ?, ?);
            """
        let prepared = try db.prepare(insert)
        let id = UUID()
        try prepared.run(id.uuidString, rec.text, rec.color, rec.created, rec.modified)
        guard db.changes == 1 else {
            throw StoreError.failure("Failed to insert entry")
        }
        return try entry(id: id)
    }

    func update(entry rec: Entry, id: UUID) throws -> Entry {
        let update = "UPDATE entry SET text=?, color=?, modified=? WHERE id=?;"
        let prepared = try db.prepare(update)
        try prepared.run(rec.text, rec.color, rec.modified, id.uuidString)
        guard db.changes == 1 else {
            throw StoreError.failure("Failed to update entry")
        }
        return try entry(id: id)
    }

    func delete(entry id: UUID) throws {
        let delete = "DELETE FROM entry WHERE id = ?"
        let prepared = try db.prepare(delete)
        try prepared.run(id.uuidString)
        guard db.changes == 1 else {
            throw StoreError.failure("Failed to delete entry")
        }
    }
}

enum StoreError: Error {
    case missing(String)
    case failure(String)
}

extension Store {

    struct Entry {
        var id: UUID
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
        self.id         = encodeUUID(row[0])!
        self.text       = row[1] as! String
        self.color      = encodeInt(row[2])!
        self.created    = encodeInt(row[3])!
        self.modified   = encodeInt(row[4])!
    }

    init(id: UUID = UUID(), text: String, color: Int = 0, modified: Int = Date.since1970, created: Int = Date.since1970) {
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

private func encodeUUID(_ value: Binding?) -> UUID? {
    guard let value = value as? String else { return nil }
    return UUID(uuidString: value)
}
