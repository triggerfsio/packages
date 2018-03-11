package main

import (
	"bufio"
	"fmt"
	"log"
	"net/rpc/jsonrpc"
	"os/exec"
	"syscall"

	"github.com/natefinch/pie"
)

const defaultFailedCode = 1

var returncode string
var stdio chan []string
var cmd *exec.Cmd

func main() {
	stdio = make(chan []string)
	log.SetPrefix("[command plugin log] ")

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
	cmd = exec.Command("bash", "-c", payload)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		log.Printf("Error setting up stdoutpipe: %s", err)
		return err
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		log.Printf("Error setting up stderrpipe: %s", err)
		return err
	}

	// start the command after having set up the pipe
	if err := cmd.Start(); err != nil {
		log.Printf("Error executing the command: %s", err)
		return err
	}
	log.Printf("Started process with pid %d\n", cmd.Process.Pid)

	var output []string
	// read command's stdout line by line
	bufout := bufio.NewScanner(stdout)
	buferr := bufio.NewScanner(stderr)

	go func() error {
		for buferr.Scan() {
			line := buferr.Text()
			output = append(output, line)
			stdio <- []string{line}
		}
		return nil
	}()

	for bufout.Scan() {
		line := bufout.Text()
		output = append(output, line)
		stdio <- []string{line}
	}

	var exitCode int
	if err := cmd.Wait(); err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			ws := exitError.Sys().(syscall.WaitStatus)
			exitCode = ws.ExitStatus()
		} else {
			exitCode = defaultFailedCode
		}
	} else {
		ws := cmd.ProcessState.Sys().(syscall.WaitStatus)
		exitCode = ws.ExitStatus()
	}
	stdio <- []string{"DONE", fmt.Sprintf("%d", exitCode)}

	*response = output
	return nil
}

func (api) Streams(data []string, response *[]string) error {
	line := <-stdio
	*response = line
	return nil
}

func (api) Kill(data []string, response *[]string) error {
	err := cmd.Process.Kill()
	if err != nil {
		return err
	}
	log.Printf("Killed process with pid %d\n", cmd.Process.Pid)
	return nil
}
