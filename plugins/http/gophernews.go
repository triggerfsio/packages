package main

import (
	"log"
	"net/rpc/jsonrpc"

	"github.com/caser/gophernews"
	"github.com/natefinch/pie"
)

var stdio chan []string

func main() {
	stdio = make(chan []string)

	log.SetPrefix("[plugin log] ")

	p := pie.NewProvider()
	if err := p.RegisterName("Plugin", api{}); err != nil {
		log.Fatalf("failed to register Plugin: %s", err)
	}

	p.ServeCodec(jsonrpc.NewServerCodec)
}

type api struct{}

func (api) Init(data []string, response *[]string) error {
	client := gophernews.NewClient()
	top, err := client.GetTop100()
	if err != nil {
		println(err)
		return err
	}

	count := 0
	for _, s := range top {
		story, err := client.GetStory(s)
		if err != nil {
			continue
		}
		stdio <- []string{story.Title, " - ", story.URL}
		count++
		if count == 10 {
			break
		}
	}

	stdio <- []string{"DONE", "200"}
	*response = nil
	return nil
}

func (api) Streams(data []string, response *[]string) error {
	line := <-stdio
	*response = line
	return nil
}

func (api) Kill(data []string, response *[]string) error {
	// we have no kill method here
	return nil
}
