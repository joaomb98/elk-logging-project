# Python Logging Template for ELK Stack

This template provides a reusable logging configuration for Python applications that send structured logs to Logstash and Elasticsearch.

## Features

- ✅ **Structured JSON Logging**: All logs are formatted as JSON for easy parsing
- ✅ **Multiple Handlers**: Console and Logstash (TCP) output
- ✅ **Environment-Based Configuration**: Uses environment variables
- ✅ **Rich Metadata**: Includes timestamp, hostname, app name, environment, and more
- ✅ **Exception Tracking**: Automatic exception logging with stack traces
- ✅ **No External Dependencies**: Uses Python standard library only

## Installation

1. Copy `logger_config.py` to your project
2. No additional dependencies required (uses Python standard library)

## Usage

### Basic Usage

```python
from logger_config import get_logger

# Create a logger
logger = get_logger('my-app')

# Log at different levels
logger.debug('Debug message')
logger.info('Info message')
logger.warning('Warning message')
logger.error('Error message')
logger.critical('Critical message')
```

### With Exception Handling

```python
from logger_config import get_logger

logger = get_logger('my-app')

try:
    # Your code here
    result = 10 / 0
except Exception as e:
    logger.error('An error occurred', exc_info=True)
```

### Custom Configuration

```python
from logger_config import get_logger
import logging

# Custom logger with specific settings
logger = get_logger(
    name='custom-app',
    enable_console=True,
    enable_logstash=True,
    log_level=logging.INFO
)
```

## Environment Variables

Configure the logger using environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_NAME` | Application name | `python-app` |
| `ENVIRONMENT` | Environment (dev/staging/prod) | `development` |
| `LOGSTASH_HOST` | Logstash hostname | `logstash` |
| `LOGSTASH_PORT` | Logstash TCP port | `5000` |

### Example

```bash
export APP_NAME=my-application
export ENVIRONMENT=production
export LOGSTASH_HOST=logs.example.com
export LOGSTASH_PORT=5000

python app.py
```

## Log Format

Each log entry is a JSON object with the following structure:

```json
{
  "timestamp": "2024-01-15T10:30:45.123456Z",
  "level": "INFO",
  "message": "User logged in",
  "logger": "my-app",
  "app_name": "my-application",
  "environment": "production",
  "hostname": "app-server-01",
  "path": "/app/main.py",
  "line": 42,
  "function": "login_user"
}
```

## Integration with Docker

### Dockerfile Example

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copy logger configuration
COPY logger_config.py .
COPY app.py .

# Set environment variables
ENV APP_NAME=my-app
ENV ENVIRONMENT=production
ENV LOGSTASH_HOST=logstash
ENV LOGSTASH_PORT=5000

CMD ["python", "app.py"]
```

### Docker Compose Example

```yaml
version: '3.8'

services:
  my-app:
    build: .
    environment:
      - APP_NAME=my-application
      - ENVIRONMENT=production
      - LOGSTASH_HOST=logstash
      - LOGSTASH_PORT=5000
    networks:
      - elk-network
```

## Log Levels

The logger supports all standard Python log levels:

- `DEBUG`: Detailed information for debugging
- `INFO`: General informational messages
- `WARNING`: Warning messages for potentially harmful situations
- `ERROR`: Error messages for serious problems
- `CRITICAL`: Critical messages for very serious errors

## Best Practices

1. **Use Appropriate Log Levels**: Don't log everything as INFO or ERROR
2. **Include Context**: Add relevant context to log messages
3. **Log Exceptions**: Always use `exc_info=True` when logging exceptions
4. **Structured Data**: Use consistent field names across your application
5. **Avoid Sensitive Data**: Don't log passwords, API keys, or personal information

## Troubleshooting

### Cannot Connect to Logstash

If the logger cannot connect to Logstash, it will:
- Print a warning message to stdout
- Continue working with console output only
- Not crash your application

```
✗ Warning: Could not connect logger 'my-app' to Logstash: [Errno 111] Connection refused
```

**Solutions:**
- Verify Logstash is running: `docker ps | grep logstash`
- Check network connectivity
- Verify environment variables are set correctly
- Ensure the ELK stack is fully started before launching your app

### No Logs in Kibana

If logs don't appear in Kibana:

1. Check if logs are being sent: `docker logs python-app`
2. Check Logstash logs: `docker logs logstash`
3. Verify Elasticsearch index: `curl http://localhost:9200/_cat/indices`
4. Check Kibana index patterns: Go to Stack Management > Index Patterns

## Advanced Usage

### Multiple Loggers

```python
from logger_config import get_logger

# Create different loggers for different components
api_logger = get_logger('api')
db_logger = get_logger('database')
cache_logger = get_logger('cache')

api_logger.info('API request received')
db_logger.debug('Database query executed')
cache_logger.warning('Cache miss')
```

### Conditional Logging

```python
import os
from logger_config import get_logger

# Disable Logstash in development
is_production = os.environ.get('ENVIRONMENT') == 'production'
logger = get_logger('my-app', enable_logstash=is_production)
```

## Testing

Test your logger configuration:

```python
from logger_config import get_logger

def test_logging():
    logger = get_logger('test-app')
    
    logger.debug('This is a debug message')
    logger.info('This is an info message')
    logger.warning('This is a warning message')
    logger.error('This is an error message')
    logger.critical('This is a critical message')
    
    # Test exception logging
    try:
        1 / 0
    except ZeroDivisionError:
        logger.error('Division by zero', exc_info=True)

if __name__ == '__main__':
    test_logging()
```

## License

This template is provided as-is for use in your projects.

## Support

For issues with the ELK logging project, please refer to the main project documentation or open an issue on GitHub.
