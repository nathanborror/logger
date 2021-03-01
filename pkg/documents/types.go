package documents

import (
	"encoding/json"
	"time"
)

// Document represents a complete database record.
type Document struct {
	Identifier string    `json:"identifier"`
	Content    Content   `json:"content"`
	History    []Content `json:"history"`
}

// Content represents the content portion of the Document.
type Content struct {
	Text     string    `json:"text"`
	Created  time.Time `json:"created"`
	Modified time.Time `json:"modified"`
	Meta     Meta      `json:"meta"`
}

// Meta represents the meta-data portion of the Content.
type Meta struct {
	ContentType string    `json:"contentType"`
	Tags        []string  `json:"tags"`
	Color       int64     `json:"color"`
	Location    *Location `json:"location,omitempty"`
}

// Location represents a location(s).
type Location struct {
	Name       string     `json:"name,omitempty"`
	Coordinate Coordinate `json:"coordinate"`
}

// Coordinate represents a geographic coordinate on Earth.
type Coordinate struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Altitude  float64 `json:"altitude"`
}

// NewDocument returns a new empty document.
func NewDocument() Document {
	now := time.Now()
	content := Content{Created: now, Modified: now}
	content.Meta = Meta{Tags: []string{}}
	return Document{Content: content, History: []Content{}}
}

// DecodeDocument returns a new document for a given JSON string.
func DecodeDocument(in string) (*Document, error) {
	var out *Document
	if err := json.Unmarshal([]byte(in), &out); err != nil {
		return nil, err
	}
	if out.History == nil {
		out.History = make([]Content, 0)
	}
	if out.Content.Meta.Tags == nil {
		out.Content.Meta.Tags = make([]string, 0)
	}
	return out, nil
}

// DecodeDocuments returns a list of documents.
func DecodeDocuments(in []string) ([]Document, error) {
	var out []Document
	for _, str := range in {
		doc, err := DecodeDocument(str)
		if err != nil {
			return nil, err
		}
		out = append(out, *doc)
	}
	if out == nil {
		out = make([]Document, 0)
	}
	return out, nil
}

// Serialize returns a JSON string of the Document.
func (d *Document) Serialize() string {
	out, _ := json.Marshal(d)
	return string(out)
}

// NewMeta returns new Meta for a given JSON string.
func NewMeta(in string) (*Meta, error) {
	var out *Meta
	if err := json.Unmarshal([]byte(in), &out); err != nil {
		return nil, err
	}
	return out, nil
}

// ToJSON returns a JSON string.
func (m Meta) ToJSON() string {
	data, _ := json.MarshalIndent(m, "", "  ")
	return string(data)
}
