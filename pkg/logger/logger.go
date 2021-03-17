package logger

import (
	"github.com/nathanborror/logger/pkg/state"
	"github.com/nathanborror/logger/pkg/state/beta"
	"github.com/nathanborror/logger/pkg/state/production"
)

const version = "1.0"

// Stater is a alias to the state package which is otherwise invisible to the ios framework.
type Stater state.Stater

// New returns and implementation of the state interface.
func New(kind, name string) Stater {
	state.Register("production", production.New)
	state.Register("beta", beta.New)
	return state.NewStater(kind, name)
}

// Version returns the current version of the framework.
func Version() string {
	return version
}
