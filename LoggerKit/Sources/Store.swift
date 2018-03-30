import Foundation
import SQLite
import UIKit

// MARK: - URLs

internal var cloudDatabaseURL: URL {
    let dir = FileManager.default.url(forUbiquityContainerIdentifier: nil)!.appendingPathComponent("Documents")
    try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir.appendingPathComponent("logger.db")
}

// MARK: - SQL Document

class SQLDocument: UIDocument {

    enum Stage {
        case none
        case loading
        case ready
    }

    private(set) var db: Connection!
    private(set) var stage: Stage = .none { didSet { handleStageDidChange(oldValue) }}

    var stageChange: ((Stage) -> Void)?

    init() {
        super.init(fileURL: cloudDatabaseURL)
        NotificationCenter.default.addObserver(self, selector: #selector(documentDidChange),
                                               name: .UIDocumentStateChanged, object: self)
    }

    override func contents(forType typeName: String) throws -> Any {
        return try Data(contentsOf: fileURL)
    }

    func handleStageDidChange(_ oldStage: Stage) {
        guard oldStage != stage else { return }
        stageChange?(stage)
    }

    @objc func documentDidChange(notification: NSNotification) {
        printDocumentState()

        guard !documentState.contains(.progressAvailable) else {
            stage = .loading
            return
        }
        guard !documentState.contains(.editingDisabled) else {
            stage = .loading
            return
        }
        guard !documentState.contains(.savingError) else {
            stage = .none // TODO: Enter into error stage
            return
        }
        guard !documentState.contains(.inConflict) else {
            stage = .none // TODO: Enter into error stage
            return
        }
        guard !documentState.contains(.closed) else {
            stage = .none // TODO: Enter into closed stage
            return
        }
        try! read(from: fileURL)
    }

    override func read(from url: URL) throws {
        print("Reading: \(url.path)")
        db = try Connection(url.absoluteString)
        stage = .ready
    }

    func printDocumentState() {
        print("documentDidChange (db: \(db != nil))")
        if documentState.contains(.progressAvailable) {
            print("\tprogressAvailable")
        }
        if documentState.contains(.editingDisabled) {
            print("\teditingDisabled")
        }
        if documentState.contains(.savingError) {
            print("\tsavingError")
        }
        if documentState.contains(.inConflict) {
            print("\tinConflict")
        }
        if documentState.contains(.closed) {
            print("\tclosed")
        }
        if documentState.contains(.normal) {
            print("\tnormal")
        }
        print("")
    }

    func forceSave() {
        guard hasUnsavedChanges else { return }
        save(to: fileURL, for: .forOverwriting, completionHandler: nil)
    }
}

// MARK: - Store

protocol StoreDelegate: class {
    func store(_ store: Store, didChangeStage stage: Store.Stage)
}

class Store {

    enum Stage {
        case none
        case loading
        case ready
    }

    let document = SQLDocument()

    weak var delegate: StoreDelegate?

    private(set) var stage: Stage = .none { didSet { handleStageDidChange(oldValue) }}
    private(set) var isDatabaseInitialized: Bool = false

    init(delegate: StoreDelegate? = nil) throws {
        self.delegate = delegate

        document.stageChange = { stage in
            switch stage {
            case .none:
                self.stage = .none
            case .loading:
                self.stage = .loading
            case .ready:
                self.stage = self.isDatabaseInitialized ? .ready : .loading
            }
        }

        document.open { success in
            try! self.setupDatabase()
        }
    }

    func handleStageDidChange(_ oldStage: Stage) {
        guard oldStage != stage else { return }
        delegate?.store(self, didChangeStage: stage)
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
            let statement = try document.db.prepare(table)
            try statement.run()
        }

        // Update internal state
        isDatabaseInitialized = true
        stage = .ready

        // Notify document of changes
        if document.db.changes > 0 {
            document.updateChangeCount(.done)
        }
    }

    func entries() throws -> EntriesResponse {
        var results: [Entry] = []
        let select = "SELECT id, text, color, created, modified FROM entry;"
        for row in try document.db.prepare(select) {
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
        for row in try document.db.prepare(select).bind(id) {
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
        let prepared = try document.db.prepare(insert)
        try prepared.run(rec.text, rec.color, rec.created, rec.modified)
        guard document.db.changes == 1 else {
            throw StoreError.failure("Failed to insert entry")
        }
        document.updateChangeCount(.done)
        document.forceSave()
        let newEntry = try entry(id: Int(document.db.lastInsertRowid))
        return newEntry
    }

    func update(entry rec: Entry, id: Int) throws -> Entry {
        let update = "UPDATE entry SET text=?, color=?, modified=? WHERE id=?;"
        let prepared = try document.db.prepare(update)
        try prepared.run(rec.text, rec.color, rec.modified, id)
        guard document.db.changes == 1 else {
            throw StoreError.failure("Failed to update entry")
        }
        document.updateChangeCount(.done)
        return try entry(id: id)
    }

    func delete(entry id: Int) throws {
        let delete = "DELETE FROM entry WHERE id = ?"
        let prepared = try document.db.prepare(delete)
        try prepared.run(id)
        guard document.db.changes == 1 else {
            throw StoreError.failure("Failed to delete entry")
        }
        document.updateChangeCount(.done)
    }

    func search(entries query: String) throws -> [Int] {
        var results: [Int?] = []
        let select = "SELECT rowid FROM entry_index WHERE entry_index MATCH 'text:\(query) * ';"
        for row in try document.db.prepare(select) {
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

    init(id: Int = 0, text: String, color: Int = 0, modified: Int = Date.since1970, created: Int = Date.since1970) {
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
