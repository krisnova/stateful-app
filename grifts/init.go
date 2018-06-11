package grifts

import (
	"github.com/gobuffalo/buffalo"
	"github.com/kris-nova/stateful_app/actions"
)

func init() {
	buffalo.Grifts(actions.App())
}
