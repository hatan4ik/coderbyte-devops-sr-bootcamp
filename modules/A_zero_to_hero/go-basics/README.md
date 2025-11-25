# Go Basics Exercises

This directory contains 5 Go exercises introducing Go programming for DevOps tasks.

## Exercises

1. **hello_world_01.go** - Basic Go program with command-line arguments
   ```bash
   go run hello_world_01.go [name]
   ```

2. **file_read_02.go** - Read files and count lines, words, characters
   ```bash
   go run file_read_02.go filename.txt
   ```

3. **simple_http_server_03.go** - HTTP server with health and hello endpoints
   ```bash
   go run simple_http_server_03.go
   # Visit: http://localhost:8080/health
   # Visit: http://localhost:8080/hello?name=DevOps
   ```

4. **json_api_client_04.go** - HTTP client for API requests
   ```bash
   go run json_api_client_04.go https://httpbin.org/json
   ```

5. **concurrent_crawler_05.go** - Concurrent web crawler using goroutines
   ```bash
   go run concurrent_crawler_05.go https://httpbin.org/delay/1 https://httpbin.org/status/200 https://httpbin.org/json
   ```

## Prerequisites

- Go 1.19+ installed
- Internet connection for HTTP exercises

## Learning Path

1. **hello_world_01.go** - Learn basic Go syntax and command-line args
2. **file_read_02.go** - File I/O and string manipulation
3. **simple_http_server_03.go** - HTTP server basics and JSON responses
4. **json_api_client_04.go** - HTTP client and JSON parsing
5. **concurrent_crawler_05.go** - Goroutines, channels, and concurrency

## Key Go Concepts Covered

- Package structure and imports
- Error handling with explicit error returns
- File I/O operations
- HTTP server and client
- JSON marshaling/unmarshaling
- Goroutines and channels
- WaitGroups for synchronization
- Struct definitions and methods

## Building Executables

To build standalone executables:
```bash
go build hello_world_01.go
./hello_world_01 DevOps
```