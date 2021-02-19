package logger

import (
	"encoding/json"
	"fmt"
)

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
