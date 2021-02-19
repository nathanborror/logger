package logger

import (
	"encoding/json"
	"testing"
)

func TestInit(t *testing.T) {
	if _, err := New(":memory:"); err != nil {
		t.Errorf(err.Error())
	}
}

func TestEntryCreate(t *testing.T) {
	db, _ := New(":memory:")
	data := db.EntryCreate("test", 0)

	var resp response
	if err := json.Unmarshal(data, &resp); err != nil {
		t.Errorf(err.Error())
	}
	if resp.Error != nil {
		t.Errorf(resp.Error.Error())
	}
	if resp.Entry == nil {
		t.Errorf("missing entry")
	}
	data = db.Entries(100, 0)
	if err := json.Unmarshal(data, &resp); err != nil {
		t.Errorf(err.Error())
	}
	if resp.Error != nil {
		t.Errorf(resp.Error.Error())
	}
	if len(resp.Entries) != 1 {
		t.Errorf("entries != 1 (%d)", len(resp.Entries))
	}
}

func TestEntryUpdate(t *testing.T) {
	db, _ := New(":memory:")
	data := db.EntryCreate("test", 0)
	resp := response{}
	if err := json.Unmarshal(data, &resp); err != nil {
		t.Errorf(err.Error())
	}
	data = db.EntryUpdate(resp.Entry.ID, "test", 0)
	if err := json.Unmarshal(data, &resp); err != nil {
		t.Errorf(err.Error())
	}
	if resp.Error != nil {
		t.Errorf(resp.Error.Error())
	}
}

func TestEntryDelete(t *testing.T) {
	db, _ := New(":memory:")
	data := db.EntryCreate("test", 0)
	resp := response{}
	if err := json.Unmarshal(data, &resp); err != nil {
		t.Errorf(err.Error())
	}
	data = db.EntryDelete(resp.Entry.ID)
	if err := json.Unmarshal(data, &resp); err != nil {
		t.Errorf(err.Error())
	}
	if resp.Error != nil {
		t.Errorf(resp.Error.Error())
	}
}

func TestEntrySearch(t *testing.T) {
	db, _ := New(":memory:")
	db.EntryCreate("foo", 0)
	db.EntryCreate("bar", 0)
	db.EntryCreate("baz", 0)

	resp := response{}
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
