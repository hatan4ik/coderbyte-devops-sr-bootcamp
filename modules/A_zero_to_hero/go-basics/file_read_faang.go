package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

type FileStats struct {
	Filename       string `json:"filename"`
	Lines          int    `json:"lines"`
	Words          int    `json:"words"`
	Characters     int    `json:"characters"`
	Bytes          int64  `json:"bytes"`
	AvgLineLength  int    `json:"avg_line_length"`
	AvgWordLength  int    `json:"avg_word_length"`
}

func analyzeFile(filename string) (*FileStats, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to open file: %w", err)
	}
	defer file.Close()

	stats := &FileStats{Filename: filename}
	
	fileInfo, err := file.Stat()
	if err != nil {
		return nil, fmt.Errorf("failed to stat file: %w", err)
	}
	stats.Bytes = fileInfo.Size()

	reader := bufio.NewReaderSize(file, 64*1024) // 64KB buffer

	for {
		line, err := reader.ReadString('\n')
		if err != nil && err != io.EOF {
			return nil, fmt.Errorf("failed to read file: %w", err)
		}

		if len(line) > 0 {
			stats.Lines++
			stats.Characters += len(line)
			
			words := strings.Fields(line)
			stats.Words += len(words)
		}

		if err == io.EOF {
			break
		}
	}

	if stats.Lines > 0 {
		stats.AvgLineLength = stats.Characters / stats.Lines
	}
	if stats.Words > 0 {
		stats.AvgWordLength = stats.Characters / stats.Words
	}

	return stats, nil
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run file_read_faang.go <filename> [--json]")
		os.Exit(1)
	}

	filename := os.Args[1]
	jsonOutput := len(os.Args) > 2 && os.Args[2] == "--json"

	log.Printf("Analyzing file: %s\n", filename)

	stats, err := analyzeFile(filename)
	if err != nil {
		log.Printf("Error: %v\n", err)
		os.Exit(1)
	}

	if jsonOutput {
		output, _ := json.MarshalIndent(stats, "", "  ")
		fmt.Println(string(output))
	} else {
		fmt.Printf("File: %s\n", stats.Filename)
		fmt.Printf("Lines: %d\n", stats.Lines)
		fmt.Printf("Words: %d\n", stats.Words)
		fmt.Printf("Characters: %d\n", stats.Characters)
		fmt.Printf("Bytes: %d\n", stats.Bytes)
		fmt.Printf("Avg Line Length: %d\n", stats.AvgLineLength)
		fmt.Printf("Avg Word Length: %d\n", stats.AvgWordLength)
	}
}
