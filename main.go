package main

import (
	"log"

	"github.com/kris-nova/stateful_app/actions"
)

func main() {
	app := actions.App()
	if err := app.Serve(); err != nil {
		log.Fatal(err)
	}
}
