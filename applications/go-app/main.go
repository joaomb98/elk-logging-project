package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net"
	"os"
	"time"
)

type LogEntry struct {
	Timestamp   string `json:"timestamp"`
	Level       string `json:"level"`
	Message     string `json:"message"`
	AppName     string `json:"app_name"`
	Environment string `json:"environment"`
	Hostname    string `json:"hostname"`
	Logger      string `json:"logger"`
}

func main() {
	logstashHost := getEnv("LOGSTASH_HOST", "logstash")
	logstashPort := getEnv("LOGSTASH_PORT", "5000")
	appName := getEnv("APP_NAME", "go-app")
	environment := getEnv("ENVIRONMENT", "development")

	hostname, _ := os.Hostname()

	fmt.Printf("Go application started - connecting to Logstash at %s:%s\n", logstashHost, logstashPort)

	counter := 0
	rand.Seed(time.Now().UnixNano())

	for {
		counter++

		var level, message string
		switch counter % 5 {
		case 0:
			level = "DEBUG"
			message = fmt.Sprintf("Debug message #%d: Application state check", counter)
		case 1:
			level = "INFO"
			message = fmt.Sprintf("Info message #%d: Processing request", counter)
		case 2:
			level = "WARNING"
			message = fmt.Sprintf("Warning message #%d: Resource usage at 75%%", counter)
		case 3:
			level = "ERROR"
			message = fmt.Sprintf("Error message #%d: Failed to connect to database", counter)
		case 4:
			level = "CRITICAL"
			message = fmt.Sprintf("Critical message #%d: System failure detected!", counter)
		}

		sendLog(logstashHost, logstashPort, appName, environment, hostname, level, message)

		sleepTime := 2 + rand.Intn(3)
		time.Sleep(time.Duration(sleepTime) * time.Second)
	}
}

func sendLog(host, port, appName, environment, hostname, level, message string) {
	logEntry := LogEntry{
		Timestamp:   time.Now().UTC().Format(time.RFC3339),
		Level:       level,
		Message:     message,
		AppName:     appName,
		Environment: environment,
		Hostname:    hostname,
		Logger:      "go-logger",
	}

	jsonLog, err := json.Marshal(logEntry)
	if err != nil {
		fmt.Printf("Error marshaling log: %v\n", err)
		return
	}

	// Print to console
	fmt.Println(string(jsonLog))

	// Send to Logstash via TCP
	conn, err := net.Dial("tcp", fmt.Sprintf("%s:%s", host, port))
	if err != nil {
		fmt.Printf("Error connecting to Logstash: %v\n", err)
		return
	}
	defer conn.Close()

	_, err = conn.Write(append(jsonLog, '\n'))
	if err != nil {
		fmt.Printf("Error sending log: %v\n", err)
	}
}

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
