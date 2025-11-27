package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"sync"
	"time"

	"golang.org/x/sync/errgroup"
	"golang.org/x/time/rate"
)

type Result struct {
	URL        string        `json:"url"`
	StatusCode int           `json:"status_code"`
	Size       int64         `json:"size"`
	Duration   time.Duration `json:"duration_ms"`
	Error      string        `json:"error,omitempty"`
}

type Crawler struct {
	client  *http.Client
	limiter *rate.Limiter
	mu      sync.Mutex
	results []Result
}

func NewCrawler(rps int) *Crawler {
	return &Crawler{
		client: &http.Client{
			Timeout: 10 * time.Second,
			Transport: &http.Transport{
				MaxIdleConns:        100,
				MaxIdleConnsPerHost: 10,
				IdleConnTimeout:     90 * time.Second,
			},
		},
		limiter: rate.NewLimiter(rate.Limit(rps), rps),
		results: make([]Result, 0),
	}
}

func (c *Crawler) crawlURL(ctx context.Context, url string) error {
	if err := c.limiter.Wait(ctx); err != nil {
		return err
	}

	start := time.Now()

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		c.addResult(Result{URL: url, Error: err.Error(), Duration: time.Since(start)})
		return err
	}

	resp, err := c.client.Do(req)
	if err != nil {
		c.addResult(Result{URL: url, Error: err.Error(), Duration: time.Since(start)})
		return err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		c.addResult(Result{URL: url, StatusCode: resp.StatusCode, Error: err.Error(), Duration: time.Since(start)})
		return err
	}

	c.addResult(Result{
		URL:        url,
		StatusCode: resp.StatusCode,
		Size:       int64(len(body)),
		Duration:   time.Since(start),
	})

	return nil
}

func (c *Crawler) addResult(r Result) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.results = append(c.results, r)
}

func (c *Crawler) Crawl(ctx context.Context, urls []string) error {
	g, ctx := errgroup.WithContext(ctx)

	for _, url := range urls {
		url := url
		g.Go(func() error {
			return c.crawlURL(ctx, url)
		})
	}

	return g.Wait()
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run concurrent_crawler_faang.go <url1> [url2] ...")
		os.Exit(1)
	}

	urls := os.Args[1:]
	crawler := NewCrawler(5) // 5 requests per second

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	start := time.Now()
	log.Printf("Crawling %d URLs with rate limiting...\n", len(urls))

	if err := crawler.Crawl(ctx, urls); err != nil {
		log.Printf("Crawl error: %v\n", err)
	}

	elapsed := time.Since(start)

	output := map[string]interface{}{
		"total_urls":     len(urls),
		"duration_ms":    elapsed.Milliseconds(),
		"results":        crawler.results,
		"success_count":  countSuccess(crawler.results),
		"failure_count":  countFailure(crawler.results),
	}

	jsonOutput, _ := json.MarshalIndent(output, "", "  ")
	fmt.Println(string(jsonOutput))
}

func countSuccess(results []Result) int {
	count := 0
	for _, r := range results {
		if r.Error == "" && r.StatusCode >= 200 && r.StatusCode < 400 {
			count++
		}
	}
	return count
}

func countFailure(results []Result) int {
	return len(results) - countSuccess(results)
}
