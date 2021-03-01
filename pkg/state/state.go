package state

import "log"

// Stater defines the state interface.
type Stater interface {
	Current() []byte
	EntryCreate(text string, color int64) []byte
	EntryUpdate(id int64, text string, color int64) []byte
	EntryDelete(id int64) []byte
	EntrySearch(query string) []byte
}

// Backend represents a state backend that can be instantiated.
type Backend func(string) Stater

// Register adds a potential backed to the registry.
func Register(kind string, backend Backend) {
	backends[kind] = backend
}

// NewStater instantiates a state backend with the given config.
func NewStater(kind string, name string) Stater {
	maker, ok := backends[kind]
	if !ok {
		log.Fatalf("Stater Error: backend '%s' not registered\n", kind)
	}
	return maker(name)
}

var backends = make(map[string]Backend)
