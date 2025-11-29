package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Metrics
var (
	httpRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "endpoint", "status"},
	)
	httpRequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "HTTP request duration in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"method", "endpoint"},
	)
	healthCheckStatus = promauto.NewGauge(
		prometheus.GaugeOpts{
			Name: "health_check_status",
			Help: "Health check status (1=healthy, 0=unhealthy)",
		},
	)
)

type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Uptime    string    `json:"uptime"`
	Version   string    `json:"version"`
}

type Server struct {
	startTime time.Time
	ready     atomic.Bool
	version   string
}

func NewServer() *Server {
	s := &Server{
		startTime: time.Now(),
		version:   "2.0.0",
	}
	s.ready.Store(true)
	healthCheckStatus.Set(1)
	return s
}

// Middleware: Logging
func (s *Server) loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		wrapped := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}
		
		next.ServeHTTP(wrapped, r)
		
		duration := time.Since(start)
		log.Printf("method=%s path=%s status=%d duration=%v", 
			r.Method, r.URL.Path, wrapped.statusCode, duration)
		
		httpRequestsTotal.WithLabelValues(
			r.Method, r.URL.Path, fmt.Sprintf("%d", wrapped.statusCode),
		).Inc()
		httpRequestDuration.WithLabelValues(r.Method, r.URL.Path).Observe(duration.Seconds())
	})
}

type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

// Handlers
func (s *Server) healthHandler(w http.ResponseWriter, r *http.Request) {
	if !s.ready.Load() {
		http.Error(w, "Service unavailable", http.StatusServiceUnavailable)
		return
	}
	
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Uptime:    time.Since(s.startTime).String(),
		Version:   s.version,
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (s *Server) readinessHandler(w http.ResponseWriter, r *http.Request) {
	if !s.ready.Load() {
		http.Error(w, "Not ready", http.StatusServiceUnavailable)
		return
	}
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, "OK")
}

func (s *Server) helloHandler(w http.ResponseWriter, r *http.Request) {
	name := r.URL.Query().Get("name")
	if name == "" {
		name = "World"
	}
	
	response := map[string]string{
		"message": fmt.Sprintf("Hello, %s!", name),
		"version": s.version,
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (s *Server) rootHandler(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"service": "FAANG HTTP Server",
		"version": s.version,
		"endpoints": []string{
			"/health",
			"/ready",
			"/hello?name=<name>",
			"/metrics",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	server := NewServer()
	
	mux := http.NewServeMux()
	mux.HandleFunc("/health", server.healthHandler)
	mux.HandleFunc("/ready", server.readinessHandler)
	mux.HandleFunc("/hello", server.helloHandler)
	mux.HandleFunc("/", server.rootHandler)
	mux.Handle("/metrics", promhttp.Handler())
	
	handler := server.loggingMiddleware(mux)
	
	httpServer := &http.Server{
		Addr:         ":8080",
		Handler:      handler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}
	
	// Graceful shutdown
	done := make(chan bool, 1)
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	
	go func() {
		<-quit
		log.Println("Server is shutting down...")
		server.ready.Store(false)
		healthCheckStatus.Set(0)
		
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		
		if err := httpServer.Shutdown(ctx); err != nil {
			log.Fatalf("Server forced to shutdown: %v", err)
		}
		close(done)
	}()
	
	log.Printf("Server starting on %s", httpServer.Addr)
	if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Server failed to start: %v", err)
	}
	
	<-done
	log.Println("Server stopped gracefully")
}
