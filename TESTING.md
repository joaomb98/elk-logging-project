# Testing Guide - ELK Logging Project

This guide covers how to test and validate the ELK logging project.

## Table of Contents

- [Automated Validation](#automated-validation)
- [Manual Testing](#manual-testing)
- [Component Testing](#component-testing)
- [Integration Testing](#integration-testing)
- [Log Level Testing](#log-level-testing)
- [Performance Testing](#performance-testing)

## Automated Validation

### Run Validation Script

```bash
./validate.sh
```

This script checks:
- ✓ Docker installation
- ✓ Docker Compose installation
- ✓ Docker Compose configuration validity
- ✓ Python syntax
- ✓ Node.js syntax
- ✓ File structure completeness
- ✓ Makefile functionality

## Manual Testing

### Test 1: Start ELK Stack

```bash
# Start ELK
make elk-up

# Wait for services
sleep 60

# Check health
make check-elk
```

**Expected Results:**
- All containers running: elasticsearch, logstash, kibana
- Elasticsearch returns cluster health
- Kibana responds on port 5601

### Test 2: Verify Elasticsearch

```bash
# Check cluster health
curl http://localhost:9200/_cluster/health?pretty

# List nodes
curl http://localhost:9200/_cat/nodes?v

# Check settings
curl http://localhost:9200/_cluster/settings?pretty
```

**Expected Output:**
```json
{
  "cluster_name" : "docker-cluster",
  "status" : "yellow",
  "number_of_nodes" : 1,
  "active_shards" : X
}
```

### Test 3: Verify Logstash

```bash
# Check Logstash API
curl http://localhost:9600/_node/stats?pretty

# View Logstash logs
docker logs logstash | tail -50
```

**Expected Output:**
- Logstash should be accepting TCP connections on port 5000
- No error messages in logs
- Pipeline should be loaded

### Test 4: Verify Kibana

```bash
# Check Kibana status
curl http://localhost:5601/api/status

# Open in browser
open http://localhost:5601  # macOS
# or
xdg-open http://localhost:5601  # Linux
```

**Expected Results:**
- Kibana UI loads successfully
- No error messages
- Can navigate to Discover

### Test 5: Start Applications

```bash
# Start all apps
make apps-up

# Verify they're running
make check-apps

# View logs
make logs-apps
```

**Expected Results:**
- 5 containers running (python-app, dotnet-app, go-app, nodejs-app, rust-app)
- Each app generating logs
- Each app connecting to Logstash

## Component Testing

### Test Python Application

```bash
# View logs
docker logs python-app -f

# Verify log generation
docker logs python-app | grep -c "level"
```

**Expected Output:**
```json
{"timestamp":"2024-01-15T10:00:00Z","level":"INFO","message":"...","app_name":"python-app",...}
```

### Test .NET Application

```bash
# View logs
docker logs dotnet-app -f

# Check for all log levels
docker logs dotnet-app | grep -E "(DEBUG|INFO|WARNING|ERROR|CRITICAL)"
```

### Test Go Application

```bash
# View logs
docker logs go-app -f

# Count log entries
docker logs go-app | wc -l
```

### Test Node.js Application

```bash
# View logs
docker logs nodejs-app -f

# Check JSON format
docker logs nodejs-app | head -1 | jq .
```

### Test Rust Application

```bash
# View logs
docker logs rust-app -f

# Verify connectivity
docker logs rust-app | grep -i "connecting"
```

## Integration Testing

### Test Log Flow (End-to-End)

```bash
# 1. Send a test log to Logstash
echo '{"timestamp":"2024-01-15T10:00:00Z","level":"TEST","message":"Integration test","app_name":"test"}' | nc localhost 5000

# 2. Wait a few seconds
sleep 5

# 3. Check if it appears in Elasticsearch
curl http://localhost:9200/logs-*/_search?q=message:Integration | jq .

# 4. Verify in Kibana
# Go to Discover and search for: message:"Integration test"
```

### Test Index Creation

```bash
# List all indices
curl http://localhost:9200/_cat/indices?v

# Check for logs indices
curl http://localhost:9200/_cat/indices?v | grep logs-
```

**Expected Output:**
```
green  open logs-2024.01.15 ...
```

### Test Log Retrieval

```bash
# Get latest logs from each app
curl -s "http://localhost:9200/logs-*/_search?size=5" | jq '.hits.hits[]._source'

# Filter by app_name
curl -s "http://localhost:9200/logs-*/_search?q=app_name:python-app&size=5" | jq .
```

## Log Level Testing

### Verify All Log Levels

Each application should generate all log levels. Test this:

```bash
# Python app
docker logs python-app | grep -o '"level":"[A-Z]*"' | sort | uniq

# Expected: CRITICAL, DEBUG, ERROR, INFO, WARNING
```

### Test Log Level Distribution

```bash
# Create a script to count log levels
cat > /tmp/count_logs.sh << 'EOF'
#!/bin/bash
APP=$1
echo "Log levels for $APP:"
docker logs $APP 2>&1 | grep -o '"level":"[A-Z]*"' | sort | uniq -c
EOF

chmod +x /tmp/count_logs.sh

# Run for each app
/tmp/count_logs.sh python-app
/tmp/count_logs.sh dotnet-app
/tmp/count_logs.sh go-app
/tmp/count_logs.sh nodejs-app
/tmp/count_logs.sh rust-app
```

## Performance Testing

### Test Log Throughput

```bash
# Generate high volume of logs
for i in {1..1000}; do
  echo '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","level":"INFO","message":"Load test '$i'","app_name":"load_test"}' | nc localhost 5000
done

# Check if all logs were indexed
curl -s "http://localhost:9200/logs-*/_count?q=app_name:load_test" | jq .
```

### Monitor Resource Usage

```bash
# Check Docker stats
docker stats --no-stream

# Check Elasticsearch heap usage
curl http://localhost:9200/_nodes/stats/jvm?pretty

# Check Logstash memory
docker stats logstash --no-stream
```

## Kibana Testing

### Test Index Pattern Creation

1. Open Kibana: http://localhost:5601
2. Go to **Stack Management** > **Index Patterns**
3. Create index pattern: `logs-*`
4. Verify it shows fields like: level, app_name, message, timestamp

### Test Discover View

1. Go to **Discover**
2. Select `logs-*` index pattern
3. Set time range to "Last 15 minutes"
4. Verify logs appear

### Test Filtering

Test these queries in Kibana:

```
app_name: "python-app"
level: "ERROR"
level: ("ERROR" OR "CRITICAL")
message: *database*
app_name: ("python-app" OR "go-app")
```

### Test Dashboard Import

```bash
# The dashboard file is at: kibana-dashboards/logs-dashboard.ndjson

# Import manually:
# 1. Go to Stack Management > Saved Objects
# 2. Click Import
# 3. Select logs-dashboard.ndjson
# 4. Click Import
```

## Template Testing

### Test Python Template

```bash
# Create a test directory
mkdir -p /tmp/test-template
cd /tmp/test-template

# Copy the template
cp /path/to/templates/python-logging-template/logger_config.py .

# Create a test app
cat > test_app.py << 'EOF'
from logger_config import get_logger

logger = get_logger('test-app')
logger.debug('Debug test')
logger.info('Info test')
logger.warning('Warning test')
logger.error('Error test')
logger.critical('Critical test')
EOF

# Run it
export LOGSTASH_HOST=localhost
export LOGSTASH_PORT=5000
export APP_NAME=test-template
python test_app.py
```

## Network Testing

### Test Network Connectivity

```bash
# Check if elk-network exists
docker network ls | grep elk-network

# Inspect the network
docker network inspect elk-network

# Verify containers are connected
docker network inspect elk-network | jq '.[0].Containers'
```

### Test Port Accessibility

```bash
# Test Elasticsearch
nc -zv localhost 9200

# Test Logstash
nc -zv localhost 5000

# Test Kibana
nc -zv localhost 5601
```

## Troubleshooting Tests

### Test: Application Can't Connect to Logstash

```bash
# From inside an application container
docker exec python-app nc -zv logstash 5000

# Check DNS resolution
docker exec python-app nslookup logstash

# Check network membership
docker inspect python-app | jq '.[0].NetworkSettings.Networks'
```

### Test: Logs Not Appearing in Elasticsearch

```bash
# Check Logstash is receiving logs
docker logs logstash | tail -20

# Check for errors in Logstash
docker logs logstash | grep -i error

# Manually test Logstash TCP input
echo '{"test":"data"}' | nc localhost 5000

# Check Elasticsearch indices
curl http://localhost:9200/_cat/indices?v
```

### Test: Elasticsearch Health Issues

```bash
# Check cluster health
curl http://localhost:9200/_cluster/health?pretty

# Check shard allocation
curl http://localhost:9200/_cat/shards?v

# Check pending tasks
curl http://localhost:9200/_cat/pending_tasks?v
```

## Cleanup After Testing

```bash
# Stop everything
make all-down

# Clean volumes
make clean

# Or clean everything
make clean-all
```

## Continuous Testing

### Create a Test Suite

Create a file `test_suite.sh`:

```bash
#!/bin/bash
set -e

echo "Running ELK Logging Project Test Suite..."

# 1. Validation
./validate.sh

# 2. Start ELK
make elk-up
sleep 60

# 3. Check ELK health
make check-elk

# 4. Start apps
make apps-up
sleep 30

# 5. Verify logs
for app in python-app dotnet-app go-app nodejs-app rust-app; do
    echo "Checking $app..."
    docker logs $app | head -5
done

# 6. Check Elasticsearch indices
curl -s http://localhost:9200/_cat/indices?v | grep logs-

# 7. Cleanup
make all-down

echo "Test suite completed successfully!"
```

## Success Criteria

A successful test should meet these criteria:

- ✓ All Docker containers running
- ✓ Elasticsearch cluster status: green or yellow
- ✓ Logstash accepting connections on port 5000
- ✓ Kibana accessible on port 5601
- ✓ All 5 applications generating logs
- ✓ All log levels present (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- ✓ Logs appearing in Elasticsearch indices
- ✓ Logs visible in Kibana Discover
- ✓ Python template working correctly
- ✓ No error messages in container logs

## Reporting Issues

When reporting issues, include:

1. Output of `./validate.sh`
2. Docker version: `docker --version`
3. Docker Compose version: `docker compose version`
4. Operating system
5. Container logs: `make logs-elk` or `make logs-apps`
6. Elasticsearch health: `curl http://localhost:9200/_cluster/health?pretty`
7. Steps to reproduce the issue

## Additional Resources

- Main README: See README.md
- Quick Start: See QUICKSTART.md
- Python Template: See templates/python-logging-template/README.md
