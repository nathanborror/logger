package alpha

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3" // driver
	"github.com/nathanborror/logger/pkg/state"
)

type manager struct {
	db *sqlx.DB
}

type entry struct {
	ID       int64  `json:"id" db:"id"`
	Text     string `json:"text" db:"text"`
	Color    int64  `json:"color" db:"color"`
	Created  int64  `json:"created" db:"created"`
	Modified int64  `json:"modified" db:"modified"`
}

type snapshot struct {
	Entries []entry `json:"entries"`
	Error   *Error  `json:"error"`
}

// New sets up a new database if one doesn't already exist.
func New(name string) state.Stater {
	conn, err := sqlx.Open("sqlite3", name)
	if err != nil {
		panic(err)
	}
	if err = conn.Ping(); err != nil {
		panic(err)
	}
	if _, err := conn.Exec(`
		CREATE TABLE IF NOT EXISTS entry (
			id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
			text text NOT NULL,
			color integer NOT NULL,
			created integer NOT NULL,
			modified integer NOT NULL
		);
		CREATE VIRTUAL TABLE IF NOT EXISTS entry_index USING fts5(text, tokenize=porter);
		CREATE TRIGGER IF NOT EXISTS after_entry_insert AFTER INSERT ON entry BEGIN
			INSERT INTO entry_index (rowid, text) VALUES (new.id, new.text);
		END;
		CREATE TRIGGER IF NOT EXISTS after_entry_update AFTER UPDATE OF text ON entry BEGIN
			UPDATE entry_index SET text = new.text WHERE rowid = old.id;
		END;
		CREATE TRIGGER IF NOT EXISTS after_entry_insert AFTER DELETE ON entry BEGIN
			DELETE FROM entry_index WHERE rowid = old.id;
		END;
	`); err != nil {
		panic(err)
	}
	return &manager{db: conn.Unsafe()}
}

// Current returns the latest entries.
func (m *manager) Current() []byte {
	var entries []entry
	if err := m.db.Select(&entries, `SELECT * FROM entry ORDER BY created DESC`); err != nil {
		return encodeError(ErrorProgrammerFailure("failed to get entries: %s", err.Error()))
	}
	return encodeEntries(entries)
}

// EntryCreate creates a new entry.
func (m *manager) EntryCreate(text string, color int64) []byte {
	now := time.Now().Unix()
	entry := entry{Text: text, Color: color, Created: now, Modified: now}
	if _, err := m.db.NamedExec(`INSERT INTO entry (text, color, created, modified) VALUES (:text, :color, :created, :modified)`, entry); err != nil {
		return encodeError(ErrorProgrammerFailure("failed to create entry: %s", err.Error()))
	}
	return m.Current()
}

// EntryUpdate updates an existing entry.
func (m *manager) EntryUpdate(id int64, text string, color int64) []byte {
	now := time.Now().Unix()
	entry := entry{ID: id, Text: text, Color: color, Modified: now}
	if _, err := m.db.NamedExec(`UPDATE entry SET text = :text, color = :color, modified = :modified WHERE id = :id`, entry); err != nil {
		return encodeError(ErrorProgrammerFailure("failed to update entry: %s", err.Error()))
	}
	return m.Current()
}

// EntryDelete deletes an existing entry.
func (m *manager) EntryDelete(id int64) []byte {
	if _, err := m.db.Exec(`DELETE FROM entry WHERE id = $1`, id); err != nil {
		return encodeError(ErrorProgrammerFailure("failed to delete entry: %s", err.Error()))
	}
	return m.Current()
}

func (m *manager) EntrySearch(query string) []byte {
	var (
		ids     []int
		entries []entry
	)
	if err := m.db.Select(&ids, `SELECT rowid FROM entry_index WHERE entry_index MATCH 'text:`+query+` * '`); err != nil {
		return encodeError(ErrorProgrammerFailure("failed to query entries: %s", err.Error()))
	}
	query, args, err := sqlx.In(`SELECT * FROM entry WHERE id IN (?)`, ids)
	if err != nil {
		return encodeError(ErrorProgrammerFailure("failed to get matched entries: %s", err.Error()))
	}
	err = m.db.Select(&entries, m.db.Rebind(query), args...)
	return encodeEntries(entries)
}

// Errors

// Error represents an error.
type Error struct {
	Code string
	Err  error
}

func (e Error) Error() string {
	return e.Code + ": " + e.Err.Error()
}

func (e *Error) Unwrap() error {
	return e.Err
}

// MarshalJSON is a custom marshaller for the Error type.
func (e Error) MarshalJSON() ([]byte, error) {
	return json.Marshal(&struct {
		Code    string `json:"code"`
		Message string `json:"message"`
	}{
		Code:    e.Code,
		Message: e.Err.Error(),
	})
}

// NewError returns a new custom Error.
func NewError(code string, message string, a ...interface{}) error {
	return Error{Code: code, Err: fmt.Errorf(message, a...)}
}

// ErrorProgrammerFailure returns a programmer failure Error.
func ErrorProgrammerFailure(message string, a ...interface{}) error {
	return NewError("ProgrammerFailure", message, a...)
}

// Private

func encodeResponse(s snapshot) []byte {
	out, err := json.Marshal(s)
	if err != nil {
		return []byte(err.Error())
	}
	return out
}

func encodeEntries(entries []entry) []byte {
	return encodeResponse(snapshot{Entries: entries})
}

func encodeError(err error) []byte {
	s := snapshot{}
	switch v := err.(type) {
	case Error:
		s.Error = &v
	case *Error:
		s.Error = v
	default:
		s.Error = &Error{Code: "Unknown", Err: err}
	}
	return encodeResponse(s)
}
