import os
import sys
import socket
import json
import logging
from logging.handlers import SocketHandler
from datetime import datetime


class LogstashFormatter(logging.Formatter):
    """
    Custom formatter to generate JSON logs for Logstash
    
    This formatter creates structured JSON logs with metadata that can be
    easily parsed and indexed by Logstash and Elasticsearch.
    """
    
    def __init__(self):
        super().__init__()
        self.hostname = socket.gethostname()
        
    def format(self, record):
        """
        Format the log record as JSON
        
        Args:
            record: LogRecord instance
            
        Returns:
            str: JSON-formatted log entry
        """
        log_data = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'level': record.levelname,
            'message': record.getMessage(),
            'logger': record.name,
            'app_name': os.environ.get('APP_NAME', 'python-app'),
            'environment': os.environ.get('ENVIRONMENT', 'development'),
            'hostname': self.hostname,
            'path': record.pathname,
            'line': record.lineno,
            'function': record.funcName,
        }
        
        # Add exception info if present
        if record.exc_info:
            log_data['exception'] = self.formatException(record.exc_info)
            
        return json.dumps(log_data)


def get_logger(name='app', enable_console=True, enable_logstash=True, log_level=logging.DEBUG):
    """
    Configure and return a logger that sends logs to Logstash
    
    This function creates a logger with multiple handlers:
    - Console handler: outputs JSON logs to stdout
    - Logstash handler: sends logs to Logstash via TCP
    
    Args:
        name (str): Logger name
        enable_console (bool): Enable console output
        enable_logstash (bool): Enable Logstash output
        log_level (int): Minimum log level (default: DEBUG)
        
    Returns:
        logging.Logger: Configured logger instance
        
    Example:
        >>> from logger_config import get_logger
        >>> logger = get_logger('my-app')
        >>> logger.info('Application started')
        >>> logger.error('An error occurred', exc_info=True)
    """
    logger = logging.getLogger(name)
    
    # Avoid duplicate handlers
    if logger.handlers:
        return logger
        
    logger.setLevel(log_level)
    
    # Console handler with JSON formatting
    if enable_console:
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(log_level)
        console_handler.setFormatter(LogstashFormatter())
        logger.addHandler(console_handler)
    
    # Logstash handler (TCP socket)
    if enable_logstash:
        logstash_host = os.environ.get('LOGSTASH_HOST', 'logstash')
        logstash_port = int(os.environ.get('LOGSTASH_PORT', 5000))
        
        try:
            logstash_handler = SocketHandler(logstash_host, logstash_port)
            logstash_handler.setLevel(log_level)
            logstash_handler.setFormatter(LogstashFormatter())
            logger.addHandler(logstash_handler)
            print(f"✓ Logger '{name}' connected to Logstash at {logstash_host}:{logstash_port}")
        except Exception as e:
            print(f"✗ Warning: Could not connect logger '{name}' to Logstash: {e}")
    
    return logger
