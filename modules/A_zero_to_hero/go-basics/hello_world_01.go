package main

import (
	"fmt"
	"os"
	"time"
)

func main() {
	if len(os.Args) > 1 {
		name := os.Args[1]
		fmt.Printf("Hello, %s!\n", name)
	} else {
		fmt.Println("Hello, World!")
	}
	
	fmt.Printf("Current time: %s\n", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Printf("Go version: %s\n", "go1.21+")
}