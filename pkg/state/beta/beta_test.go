package beta

import (
	"encoding/json"
	"strconv"
	"testing"
)

func TestEntryCreate(t *testing.T) {
	db := New(":memory:")
	data := db.EntryCreate("test", 0)

	var s snapshot
	if err := json.Unmarshal(data, &s); err != nil {
		t.Errorf(err.Error())
	}
	if s.Error != nil {
		t.Errorf(s.Error.Error())
	}
	if len(s.Documents) != 1 {
		t.Errorf("missing document")
	}
	data = db.Current()
	if err := json.Unmarshal(data, &s); err != nil {
		t.Errorf(err.Error())
	}
	if s.Error != nil {
		t.Errorf(s.Error.Error())
	}
	if len(s.Documents) != 1 {
		t.Errorf("documents != 1 (%d)", len(s.Documents))
	}
}

func TestEntryUpdate(t *testing.T) {
	db := New(":memory:")
	data := db.EntryCreate("test", 0)
	s := snapshot{}
	if err := json.Unmarshal(data, &s); err != nil {
		t.Errorf(err.Error())
	}
	doc := s.Documents[0]
	id, err := strconv.ParseInt(doc.Identifier, 10, 64)
	if err != nil {
		t.Errorf(err.Error())
	}
	data = db.EntryUpdate(id, "test", 0)
	if err := json.Unmarshal(data, &s); err != nil {
		t.Errorf(err.Error())
	}
	if s.Error != nil {
		t.Errorf(s.Error.Error())
	}
}

func TestEntryDelete(t *testing.T) {
	db := New(":memory:")
	data := db.EntryCreate("test", 0)
	s := snapshot{}
	if err := json.Unmarshal(data, &s); err != nil {
		t.Errorf(err.Error())
	}
	doc := s.Documents[0]
	id, err := strconv.ParseInt(doc.Identifier, 10, 64)
	if err != nil {
		t.Errorf(err.Error())
	}
	data = db.EntryDelete(id)
	if err := json.Unmarshal(data, &s); err != nil {
		t.Errorf(err.Error())
	}
	if s.Error != nil {
		t.Errorf(s.Error.Error())
	}
}

// func TestEntrySearch(t *testing.T) {
// 	db, _ := New(":memory:")
// 	db.EntryCreate("foo", 0)
// 	db.EntryCreate("bar", 0)
// 	db.EntryCreate("baz", 0)

// 	resp := snapshot{}
// 	data := db.EntrySearch("foo")
// 	if err := json.Unmarshal(data, &resp); err != nil {
// 		t.Errorf(err.Error())
// 	}
// 	if len(resp.Documents) != 1 {
// 		t.Errorf("missing entry (%d)", len(resp.Documents))
// 	}
// 	if resp.Error != nil {
// 		t.Errorf(resp.Error.Error())
// 	}
// }
