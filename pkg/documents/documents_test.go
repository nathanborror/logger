package documents

import (
	"testing"
)

func TestDocumentCreation(t *testing.T) {
	db, _ := New(":memory:")
	id := "ce44fd85-c7dd-4570-8900-d75d8207391f"
	content := Content{
		Text: "Foo",
		Meta: Meta{ContentType: "post", Tags: []string{"foo"}},
	}
	if err := db.DocumentSave(id, content); err != nil {
		t.Error(err)
	}
	if _, err := db.DocumentForIdentifier(id); err != nil {
		t.Error(err)
	}
	if err := db.DocumentDelete(id); err != nil {
		t.Error(err)
	}
}

func TestDocumentUniqueSlug(t *testing.T) {
	db, _ := New(":memory:")
	content := Content{Text: "Foo"}

	if err := db.DocumentSave("foo", content); err != nil {
		t.Error(err)
	}
	if err := db.DocumentSave("foo", content); err != nil {
		t.Error(err)
	}
}

func TestDocuments(t *testing.T) {
	db, _ := New(":memory:")
	doc1 := Document{
		Identifier: "ce44fd85-c7dd-4570-8900-d75d8207391f",
		Content: Content{
			Text: "foo",
			Meta: Meta{ContentType: "post", Tags: []string{"foo"}},
		},
	}
	doc2 := Document{
		Identifier: "6ee9ad8e-38cd-40c6-81b7-dac0119ef7b9",
		Content: Content{
			Text: "bar",
			Meta: Meta{ContentType: "post", Tags: []string{"foo", "bar"}},
		},
	}
	db.DocumentSave(doc1.Identifier, doc1.Content)
	db.DocumentSave(doc2.Identifier, doc2.Content)

	docs, err := db.Documents()
	if err != nil {
		t.Error(err)
	}
	if len(docs) != 2 {
		t.Errorf("docs != 2")
	}
}

func TestDocumentTags(t *testing.T) {
	db, _ := New(":memory:")
	doc1 := Document{
		Identifier: "ce44fd85-c7dd-4570-8900-d75d8207391f",
		Content: Content{
			Text: "foo",
			Meta: Meta{ContentType: "post", Tags: []string{"foo"}},
		},
	}
	doc2 := Document{
		Identifier: "6ee9ad8e-38cd-40c6-81b7-dac0119ef7b9",
		Content: Content{
			Text: "bar",
			Meta: Meta{ContentType: "post", Tags: []string{"foo", "bar"}},
		},
	}
	doc3 := Document{
		Identifier: "1e79099a-9ed9-4dab-a287-31d6d5106067",
		Content: Content{
			Text: "baz",
			Meta: Meta{ContentType: "post", Tags: []string{"baz"}},
		},
	}
	db.DocumentSave(doc1.Identifier, doc1.Content)
	db.DocumentSave(doc2.Identifier, doc2.Content)
	db.DocumentSave(doc3.Identifier, doc3.Content)

	docs, err := db.DocumentsForTag("foo")
	if err != nil {
		t.Error(err)
	}
	if len(docs) != 2 {
		t.Errorf("docs != 2 (%+v)", docs)
	}
}

func TestDocumentContentType(t *testing.T) {
	db, _ := New(":memory:")
	doc1 := Document{
		Identifier: "ce44fd85-c7dd-4570-8900-d75d8207391f",
		Content: Content{
			Text: "foo",
			Meta: Meta{ContentType: "page"},
		},
	}
	doc2 := Document{
		Identifier: "6ee9ad8e-38cd-40c6-81b7-dac0119ef7b9",
		Content: Content{
			Text: "bar",
			Meta: Meta{ContentType: "post"},
		},
	}
	doc3 := Document{
		Identifier: "1e79099a-9ed9-4dab-a287-31d6d5106067",
		Content: Content{
			Text: "baz",
			Meta: Meta{ContentType: "post"},
		},
	}
	db.DocumentSave(doc1.Identifier, doc1.Content)
	db.DocumentSave(doc2.Identifier, doc2.Content)
	db.DocumentSave(doc3.Identifier, doc3.Content)

	docs, err := db.DocumentsForContentType("post")
	if err != nil {
		t.Error(err)
	}
	if len(docs) != 2 {
		t.Errorf("docs != 2 (%+v)", docs)
	}
}
