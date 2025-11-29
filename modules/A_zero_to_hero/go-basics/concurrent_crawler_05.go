package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"sync"
	"time"
)

type Result struct {
	URL        string
	StatusCode int
	Size       int64
	Duration   time.Duration
	Error      error
}

func crawlURL(url string, results chan<- Result, wg *sync.WaitGroup) {
	defer wg.Done()
	
	start := time.Now()
	
	client := &http.Client{
		Timeout: 10 * time.Second,
	}
	
	resp, err := client.Get(url)
	if err != nil {
		results <- Result{URL: url, Error: err, Duration: time.Since(start)}
		return
	}
	defer resp.Body.Close()
	
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		results <- Result{URL: url, StatusCode: resp.StatusCode, Error: err, Duration: time.Since(start)}
		return
	}
	
	results <- Result{
		URL:        url,
		StatusCode: resp.StatusCode,
		Size:       int64(len(body)),
		Duration:   time.Since(start),
	}
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run concurrent_crawler_05.go <url1> [url2] [url3] ...")
		os.Exit(1)
	}
	
	urls := os.Args[1:]
	results := make(chan Result, len(urls))
	var wg sync.WaitGroup
	
	fmt.Printf("Crawling %d URLs concurrently...\n\n", len(urls))
	start := time.Now()
	
	// Start goroutines
	for _, url := range urls {
		wg.Add(1)
		go crawlURL(url, results, &wg)
	}
	
	// Wait for all goroutines to complete
	go func() {
		wg.Wait()
		close(results)
	}()
	
	// Collect results
	for result := range results {
		if result.Error != nil {
			fmt.Printf("❌ %s: Error - %v (%.2fs)\n", result.URL, result.Error, result.Duration.Seconds())
		} else {
			fmt.Printf("✅ %s: %d - %d bytes (%.2fs)\n", 
				result.URL, result.StatusCode, result.Size, result.Duration.Seconds())
		}
	}
	
	fmt.Printf("\nTotal time: %.2fs\n", time.Since(start).Seconds())
}