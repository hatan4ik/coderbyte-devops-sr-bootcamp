package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"
)

type CircuitBreaker struct {
	maxFailures  int
	timeout      time.Duration
	failures     int
	lastFailTime time.Time
	state        string
}

func NewCircuitBreaker() *CircuitBreaker {
	return &CircuitBreaker{
		maxFailures: 3,
		timeout:     60 * time.Second,
		state:       "closed",
	}
}

func (cb *CircuitBreaker) Call(fn func() error) error {
	if cb.state == "open" {
		if time.Since(cb.lastFailTime) > cb.timeout {
			cb.state = "half-open"
		} else {
			return fmt.Errorf("circuit breaker is open")
		}
	}

	err := fn()
	if err != nil {
		cb.failures++
		cb.lastFailTime = time.Now()
		if cb.failures >= cb.maxFailures {
			cb.state = "open"
		}
		return err
	}

	cb.failures = 0
	cb.state = "closed"
	return nil
}

type APIClient struct {
	client  *http.Client
	breaker *CircuitBreaker
}

func NewAPIClient() *APIClient {
	return &APIClient{
		client: &http.Client{
			Timeout: 10 * time.Second,
		},
		breaker: NewCircuitBreaker(),
	}
}

func (c *APIClient) FetchWithRetry(ctx context.Context, url string, maxRetries int) (map[string]interface{}, error) {
	var result map[string]interface{}
	var lastErr error

	for attempt := 0; attempt < maxRetries; attempt++ {
		if attempt > 0 {
			delay := time.Duration(1<<uint(attempt-1)) * time.Second
			log.Printf("Retry %d/%d after %v\n", attempt+1, maxRetries, delay)
			time.Sleep(delay)
		}

		err := c.breaker.Call(func() error {
			var err error
			result, err = c.fetch(ctx, url)
			return err
		})

		if err == nil {
			return result, nil
		}
		lastErr = err
	}

	return nil, fmt.Errorf("failed after %d retries: %v", maxRetries, lastErr)
}

func (c *APIClient) fetch(ctx context.Context, url string) (map[string]interface{}, error) {
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, err
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var data map[string]interface{}
	if err := json.Unmarshal(body, &data); err != nil {
		return map[string]interface{}{
			"status":       resp.StatusCode,
			"content_type": resp.Header.Get("Content-Type"),
			"body":         string(body[:min(500, len(body))]),
		}, nil
	}

	return map[string]interface{}{
		"status":       resp.StatusCode,
		"content_type": resp.Header.Get("Content-Type"),
		"data":         data,
	}, nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run json_api_client_faang.go <url>")
		os.Exit(1)
	}

	url := os.Args[1]
	client := NewAPIClient()

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	log.Printf("Fetching: %s\n", url)

	result, err := client.FetchWithRetry(ctx, url, 3)
	if err != nil {
		log.Printf("Error: %v\n", err)
		os.Exit(1)
	}

	output, _ := json.MarshalIndent(result, "", "  ")
	fmt.Println(string(output))
}
