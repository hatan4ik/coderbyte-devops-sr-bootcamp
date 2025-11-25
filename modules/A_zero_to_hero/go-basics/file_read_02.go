package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run file_read_02.go <filename>")
		os.Exit(1)
	}

	filename := os.Args[1]
	file, err := os.Open(filename)
	if err != nil {
		fmt.Printf("Error opening file: %v\n", err)
		os.Exit(1)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lineCount := 0
	wordCount := 0
	charCount := 0

	for scanner.Scan() {
		line := scanner.Text()
		lineCount++
		words := strings.Fields(line)
		wordCount += len(words)
		charCount += len(line)
	}

	if err := scanner.Err(); err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("File: %s\n", filename)
	fmt.Printf("Lines: %d\n", lineCount)
	fmt.Printf("Words: %d\n", wordCount)
	fmt.Printf("Characters: %d\n", charCount)
}