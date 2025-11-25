package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

type APIResponse struct {
	Status int                    `json:"status"`
	Data   map[string]interface{} `json:"data"`
}

func fetchAPI(url string) error {
	client := &http.Client{
		Timeout: 10 * time.Second,
	}
	
	resp, err := client.Get(url)
	if err != nil {
		return fmt.Errorf("request failed: %v", err)
	}
	defer resp.Body.Close()
	
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response: %v", err)
	}
	
	fmt.Printf("Status Code: %d\n", resp.StatusCode)
	fmt.Printf("Content-Type: %s\n", resp.Header.Get("Content-Type"))
	
	// Try to parse as JSON
	var jsonData map[string]interface{}
	if err := json.Unmarshal(body, &jsonData); err == nil {
		fmt.Println("Response (JSON):")
		prettyJSON, _ := json.MarshalIndent(jsonData, "", "  ")
		fmt.Println(string(prettyJSON))
	} else {
		fmt.Println("Response (Text):")
		if len(body) > 500 {
			fmt.Printf("%s...\n", string(body[:500]))
		} else {
			fmt.Println(string(body))
		}
	}
	
	return nil
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run json_api_client_04.go <url>")
		os.Exit(1)
	}
	
	url := os.Args[1]
	if err := fetchAPI(url); err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
}