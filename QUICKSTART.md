# Quick Start Guide - ELK Logging Project

This guide will help you get the ELK logging project up and running in minutes.

## Prerequisites

- Docker (>= 20.10)
- Docker Compose (>= 2.0)
- 4GB RAM available
- 10GB disk space

## Quick Start (3 Steps)

### Step 1: Start ELK Stack

```bash
make elk-up
```

Wait 60 seconds for all services to initialize.

### Step 2: Verify ELK is Running

```bash
make check-elk
```

Expected output:
- Elasticsearch should show `"status" : "green"` or `"status" : "yellow"`
- Kibana should respond on port 5601
- Docker containers should be running

### Step 3: Start Applications

```bash
make apps-up
```

This will start 5 applications that send logs to Logstash:
- Python app
- .NET app
- Go app
- Node.js app
- Rust app

## Accessing Services

- **Kibana**: http://localhost:5601
- **Elasticsearch**: http://localhost:9200
- **Logstash**: localhost:5000 (TCP)

## View Logs

### View logs from all applications:
```bash
make logs-apps
```

### View logs from a specific app:
```bash
make logs-python
make logs-dotnet
make logs-go
make logs-nodejs
make logs-rust
```

### View ELK Stack logs:
```bash
make logs-elk
```

## Kibana Setup

1. Open Kibana: http://localhost:5601
2. Wait for Kibana to fully load
3. Go to **Stack Management** → **Index Patterns**
4. Click **Create index pattern**
5. Enter: `logs-*`
6. Select `@timestamp` as the time field
7. Click **Create index pattern**
8. Go to **Discover** to view logs

## Useful Kibana Queries

```
# View logs from Python app
app_name: "python-app"

# View error logs
level: ("ERROR" OR "CRITICAL")

# View logs from last 15 minutes
(Set time range in Kibana UI)

# Search for specific text
message: *database*
```

## Stopping Services

### Stop applications:
```bash
make apps-down
```

### Stop ELK Stack:
```bash
make elk-down
```

### Stop everything:
```bash
make all-down
```

## Troubleshooting

### ELK Stack not starting

```bash
# Check logs
make logs-elk

# On Linux, you may need to increase vm.max_map_count
sudo sysctl -w vm.max_map_count=262144
```

### Applications can't connect to Logstash

```bash
# Verify Logstash is running
docker ps | grep logstash

# Check network
docker network inspect elk-network

# Restart applications
make apps-restart
```

### No logs in Kibana

```bash
# Verify indices exist
curl http://localhost:9200/_cat/indices?v

# Check if logs are being generated
make logs-python

# Verify Logstash is receiving logs
docker logs logstash | tail -20
```

## Clean Up

### Remove all containers and volumes:
```bash
make clean
```

### Remove everything including images:
```bash
make clean-all
```

## Next Steps

1. Explore logs in Kibana Discover
2. Create custom visualizations
3. Import the pre-configured dashboard from `kibana-dashboards/`
4. Use the Python logging template for your own projects
5. Customize log levels and formats

## Getting Help

- Check the main README.md for detailed documentation
- Review the Python template documentation in `templates/python-logging-template/README.md`
- Check application-specific README files

## Common Make Commands

```bash
make help              # Show all available commands
make elk-up            # Start ELK Stack
make elk-down          # Stop ELK Stack
make apps-up           # Start all applications
make apps-down         # Stop all applications
make all-up            # Start everything
make all-down          # Stop everything
make status            # Check status of all services
make logs-apps         # View application logs
make logs-elk          # View ELK logs
make clean             # Clean up volumes
```

## Architecture Overview

```
Applications (Python, .NET, Go, Node.js, Rust)
         ↓
    JSON Logs (TCP Port 5000)
         ↓
      Logstash (Parse & Enrich)
         ↓
   Elasticsearch (Store & Index)
         ↓
      Kibana (Visualize)
```

## Log Format

All applications send structured JSON logs:

```json
{
  "timestamp": "2024-01-15T10:30:45.123456Z",
  "level": "INFO",
  "message": "Processing request",
  "app_name": "python-app",
  "environment": "development",
  "hostname": "container-id",
  "logger": "app-logger"
}
```

## Support

For issues or questions, check the main README.md or open an issue on GitHub.
