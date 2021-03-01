package beta

import (
	"encoding/json"
	"fmt"
	"time"

	_ "github.com/mattn/go-sqlite3" // driver
	"github.com/nathanborror/logger/pkg/documents"
	"github.com/nathanborror/logger/pkg/state"
)

type manager struct {
	docs *documents.Documents
}

type snapshot struct {
	Documents []documents.Document `json:"documents"`
	Error     *Error               `json:"error"`
}

// New sets up a new database if one doesn't already exist.
func New(name string) state.Stater {
	docs, err := documents.New(name)
	if err != nil {
		panic(err)
	}
	return &manager{docs: docs}
}

// Current returns the latest entries.
func (m *manager) Current() []byte {
	documents, err := m.docs.Documents()
	if err != nil {
		return encodeError(err)
	}
	return encodeDocuments(documents)
}

// EntryCreate creates a new entry.
func (m *manager) EntryCreate(text string, color int64) []byte {
	id := fmt.Sprintf("%d", time.Now().Unix())

	// TODO: Convert ids to hashes
	// Example: id, _ := hashids.New()

	doc := documents.NewDocument()
	doc.Content.Text = text
	doc.Content.Meta.Color = color

	if err := m.docs.DocumentSave(id, doc.Content); err != nil {
		return encodeError(err)
	}
	return m.Current()
}

// EntryUpdate updates an existing entry.
func (m *manager) EntryUpdate(id int64, text string, color int64) []byte {
	document, err := m.docs.DocumentForIdentifier(fmt.Sprintf("%d", id))
	if err != nil {
		return encodeError(err)
	}
	document.Content.Text = text
	document.Content.Meta.Color = color

	if err := m.docs.DocumentSave(document.Identifier, document.Content); err != nil {
		return encodeError(err)
	}
	return m.Current()
}

// EntryDelete deletes an existing entry.
func (m *manager) EntryDelete(id int64) []byte {
	if err := m.docs.DocumentDelete(fmt.Sprintf("%d", id)); err != nil {
		return encodeError(err)
	}
	return m.Current()
}

func (m *manager) EntrySearch(query string) []byte {
	return encodeError(fmt.Errorf("search not implemented"))
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

func encodeDocuments(documents []documents.Document) []byte {
	return encodeResponse(snapshot{Documents: documents})
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
