package production

import (
	"encoding/json"
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
	if len(s.Entries) != 1 {
		t.Errorf("missing entry")
	}
	data = db.Current()
	if err := json.Unmarshal(data, &s); err != nil {
		t.Errorf(err.Error())
	}
	if s.Error != nil {
		t.Errorf(s.Error.Error())
	}
	if len(s.Entries) != 1 {
		t.Errorf("entries != 1 (%d)", len(s.Entries))
	}
}

func TestEntryUpdate(t *testing.T) {
	db := New(":memory:")
	data := db.EntryCreate("test", 0)
	s := snapshot{}
	if err := json.Unmarshal(data, &s); err != nil {
		t.Errorf(err.Error())
	}
	entry := s.Entries[0]
	data = db.EntryUpdate(entry.ID, "test", 0)
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
	entry := s.Entries[0]
	data = db.EntryDelete(entry.ID)
	if err := json.Unmarshal(data, &s); err != nil {
		t.Errorf(err.Error())
	}
	if s.Error != nil {
		t.Errorf(s.Error.Error())
	}
}

func TestEntrySearch(t *testing.T) {
	db := New(":memory:")
	db.EntryCreate("foo", 0)
	db.EntryCreate("bar", 0)
	db.EntryCreate("baz", 0)

	resp := snapshot{}
	data := db.EntrySearch("foo")
	if err := json.Unmarshal(data, &resp); err != nil {
		t.Errorf(err.Error())
	}
	if len(resp.Entries) != 1 {
		t.Errorf("missing entry (%d)", len(resp.Entries))
	}
	if resp.Error != nil {
		t.Errorf(resp.Error.Error())
	}
}
