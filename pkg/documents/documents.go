package documents

import (
	"database/sql"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3" // driver
)

// Documents represents the interface for interacting with Documents.
type Documents struct {
	db *sqlx.DB
}

// New returns a database interface for interacting with Documents.
func New(name string) (*Documents, error) {
	conn, err := sqlx.Open("sqlite3", name)
	if err != nil {
		return nil, err
	}
	if err = conn.Ping(); err != nil {
		return nil, err
	}
	if _, err := conn.Exec(`
		CREATE TABLE IF NOT EXISTS document (
			document    TEXT NOT NULL,
			identifier  TEXT GENERATED ALWAYS AS (json_extract(document, '$.identifier')) VIRTUAL NOT NULL UNIQUE,
			contentType TEXT GENERATED ALWAYS AS (json_extract(document, '$.content.meta.contentType')) VIRTUAL NOT NULL,
			tags        TEXT GENERATED ALWAYS AS (json_extract(document, '$.content.meta.tags')) VIRTUAL,
			created     DATETIME GENERATED ALWAYS AS (json_extract(document, '$.content.created')) VIRTUAL NOT NULL,
			modified    DATETIME GENERATED ALWAYS AS (json_extract(document, '$.content.modified')) VIRTUAL NOT NULL
		);

		CREATE VIRTUAL TABLE IF NOT EXISTS search_document_tags USING fts5(tags);
		PRAGMA RECURSIVE_TRIGGERS = true;
		CREATE TRIGGER IF NOT EXISTS after_document_insert AFTER INSERT ON document BEGIN
			INSERT INTO search_document_tags (rowid, tags) VALUES (new.rowid, new.tags);
		END;
		CREATE TRIGGER IF NOT EXISTS after_document_delete AFTER DELETE ON document BEGIN
			DELETE FROM search_document_tags WHERE rowid = old.rowid;
		END;
	`); err != nil {
		return nil, err
	}
	return &Documents{db: conn.Unsafe()}, nil
}

// Documents returns all documents.
func (d *Documents) Documents() ([]Document, error) {
	var strs []string
	if err := d.db.Select(&strs, `SELECT document FROM document ORDER BY created DESC`); err != nil {
		return nil, err
	}
	return DecodeDocuments(strs)
}

// DocumentsForContentType returns all documents for a given content-type.
func (d *Documents) DocumentsForContentType(contentType string) ([]Document, error) {
	var strs []string
	if err := d.db.Select(&strs, `SELECT document FROM document WHERE contentType = ? ORDER BY created DESC`, contentType); err != nil {
		return nil, err
	}
	return DecodeDocuments(strs)
}

// DocumentsForTag returns all documents matching the given tag.
func (d *Documents) DocumentsForTag(tag string) ([]Document, error) {
	var (
		ids  []int64
		strs []string
	)
	if err := d.db.Select(&ids, `SELECT rowid FROM search_document_tags WHERE search_document_tags MATCH 'tags:`+tag+` * '`); err != nil {
		return nil, err
	}
	if len(ids) == 0 {
		return nil, sql.ErrNoRows
	}
	query, args, err := sqlx.In(`SELECT document FROM document WHERE rowid IN (?) ORDER BY created DESC`, ids)
	if err != nil {
		return nil, err
	}
	if err := d.db.Select(&strs, query, args...); err != nil {
		return nil, err
	}
	return DecodeDocuments(strs)
}

// DocumentForIdentifier returns a document for a given identifier.
func (d *Documents) DocumentForIdentifier(id string) (*Document, error) {
	var str string
	if err := d.db.Get(&str, `SELECT document FROM document WHERE identifier = ?`, id); err != nil {
		return nil, err
	}
	return DecodeDocument(str)
}

// DocumentSave returns a created or updated document, maintaining a history of edits.
func (d *Documents) DocumentSave(id string, content Content) error {
	doc, _ := d.DocumentForIdentifier(id)
	if doc == nil {
		doc = &Document{Identifier: id, Content: content}
	} else {
		doc.History = append(doc.History, doc.Content)
		doc.Content = content
	}
	_, err := d.db.Exec(`INSERT OR REPLACE INTO document (document) VALUES (?)`, doc.Serialize())
	return err
}

// DocumentDelete removes a document from storage.
func (d *Documents) DocumentDelete(id string) error {
	_, err := d.db.Exec(`DELETE FROM document WHERE identifier = ?`, id)
	return err
}
