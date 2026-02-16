import os
import sys
import socket
import json
import logging
from logging.handlers import SocketHandler
from datetime import datetime
import time


class LogstashFormatter(logging.Formatter):
    """Custom formatter to generate JSON logs for Logstash"""
    
    def __init__(self):
        super().__init__()
        self.hostname = socket.gethostname()
        
    def format(self, record):
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


def get_logger(name='app'):
    """
    Configure and return a logger that sends logs to Logstash
    
    Args:
        name: Logger name
        
    Returns:
        logging.Logger: Configured logger instance
    """
    logger = logging.getLogger(name)
    
    # Avoid duplicate handlers
    if logger.handlers:
        return logger
        
    logger.setLevel(logging.DEBUG)
    
    # Console handler with JSON formatting
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.DEBUG)
    console_handler.setFormatter(LogstashFormatter())
    logger.addHandler(console_handler)
    
    # Logstash handler (TCP socket)
    logstash_host = os.environ.get('LOGSTASH_HOST', 'logstash')
    logstash_port = int(os.environ.get('LOGSTASH_PORT', 5000))
    
    try:
        logstash_handler = SocketHandler(logstash_host, logstash_port)
        logstash_handler.setLevel(logging.DEBUG)
        logstash_handler.setFormatter(LogstashFormatter())
        logger.addHandler(logstash_handler)
        print(f"✓ Connected to Logstash at {logstash_host}:{logstash_port}")
    except Exception as e:
        print(f"✗ Warning: Could not connect to Logstash: {e}")
    
    return logger
