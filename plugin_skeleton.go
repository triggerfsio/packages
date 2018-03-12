package main

import (
	"log"
	"net/rpc/jsonrpc"

	"github.com/natefinch/pie"
)

var stdio chan []string

func main() {
	// initialize stdoi channel
	stdio = make(chan []string)

	// set prefix of module logger.
	// the logs in the terminal where the worker is running will be prefixed with this string.
	log.SetPrefix("[awesomeplugin log] ")

	// mandatory:
	// we initialize a new provider provided by the pie package
	p := pie.NewProvider()

	// we HAVE to register the name of this plugin with the string "Plugin"
	if err := p.RegisterName("Plugin", api{}); err != nil {
		log.Fatalf("failed to register Plugin: %s", err)
	}
	p.ServeCodec(jsonrpc.NewServerCodec)
}

type api struct{}

// NOTE: you HAVE to have a function called "Init". this is the entrance of the worker process calling your plugin
func (api) Init(data []string, response *[]string) error {
	// check if we receive data at all or return.
	// you can skip this if your plugin doesn't expect any input data
	if len(data) == 0 {
		return nil
	}

	// if you get data, you will get your payload in data[0]
	payload := data[0]

	// or, additionally, maybe the client can pass more than one argument. then you can work with data[0:]
	// payload := data[0:]

	// do something with payload
	log.Print(payload)

	// occasionally update the client with information in realtime
	stdio <- []string{"look, what I'm doing..."}

	// end realtime stream to client with "DONE" followed by a return code ("200" is hardcoded as success. the number is up to you.)
	// NOTE: you HAVE to send a "DONE" followed by a return code in the same slice. also, you HAVE to send this message to end the stream to the client!!!
	stdio <- []string{"DONE", "200"}

	// give something back to our worker process (not in use, yet.)
	*response = []string{}
	return nil
}

// NOTE: you HAVE to have a function called "Streams"
// THIS FUNCTION HAS TO EXIST (DON'T change the function body)
func (api) Streams(data []string, response *[]string) error {
	line := <-stdio
	*response = line
	return nil
}

// NOTE: you HAVE to have a function called "Kill"
// THIS FUNCTION HAS TO EXIST (you can change the function body. for example if you have no process to kill, just return)
func (api) Kill(data []string, response *[]string) error {
	// we have no kill method here
	return nil
}
