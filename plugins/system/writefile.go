package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/rpc/jsonrpc"

	"github.com/natefinch/pie"
)

var stdio chan []string

type Payload struct {
	Path    string `json:"path"`
	Content string `json:"content,omitempty"`
}

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
	if len(data) == 0 {
		return nil
	}

	payload := data[0]

	var jsonpayload *Payload
	err := json.Unmarshal([]byte(payload), &jsonpayload)
	if err != nil {
		stdio <- []string{err.Error()}
		stdio <- []string{"DONE", "500"}
		return err
	}

	if len(jsonpayload.Path) == 0 {
		stdio <- []string{"No path specified. Need path to file to write to"}
		stdio <- []string{"DONE", "500"}
		return nil
	}

	err = ioutil.WriteFile(jsonpayload.Path, []byte(jsonpayload.Content), 0644)
	if err != nil {
		stdio <- []string{fmt.Errorf("Error occured while writing to file: %s", err).Error()}
		stdio <- []string{"DONE", "500"}
		return err
	}

	stdio <- []string{"DONE", "200"}
	*response = []string{}
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
