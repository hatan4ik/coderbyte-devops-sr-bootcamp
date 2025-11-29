package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"runtime"
	"time"
)

type GreetingOutput struct {
	Message   string    `json:"message"`
	Timestamp time.Time `json:"timestamp"`
	Version   string    `json:"version"`
	GoVersion string    `json:"go_version"`
	OS        string    `json:"os"`
	Arch      string    `json:"arch"`
}

func main() {
	name := flag.String("name", "World", "Name to greet")
	jsonOutput := flag.Bool("json", false, "Output as JSON")
	verbose := flag.Bool("verbose", false, "Verbose output")
	flag.Parse()

	greeting := GreetingOutput{
		Message:   fmt.Sprintf("Hello, %s!", *name),
		Timestamp: time.Now(),
		Version:   "2.0.0",
		GoVersion: runtime.Version(),
		OS:        runtime.GOOS,
		Arch:      runtime.GOARCH,
	}

	if *jsonOutput {
		output, err := json.MarshalIndent(greeting, "", "  ")
		if err != nil {
			log.Printf("Error marshaling JSON: %v\n", err)
			os.Exit(1)
		}
		fmt.Println(string(output))
	} else {
		fmt.Println(greeting.Message)
		
		if *verbose {
			fmt.Printf("Timestamp: %s\n", greeting.Timestamp.Format(time.RFC3339))
			fmt.Printf("Version: %s\n", greeting.Version)
			fmt.Printf("Go Version: %s\n", greeting.GoVersion)
			fmt.Printf("OS/Arch: %s/%s\n", greeting.OS, greeting.Arch)
		}
	}
}
