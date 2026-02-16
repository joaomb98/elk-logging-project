import time
import random
from logger_config import get_logger

def main():
    logger = get_logger('python-app')
    
    logger.info("Python application started - generating test logs")
    
    counter = 0
    
    while True:
        counter += 1
        
        # Generate different log levels
        log_type = counter % 5
        
        if log_type == 0:
            logger.debug(f"Debug message #{counter}: Application state check")
        elif log_type == 1:
            logger.info(f"Info message #{counter}: Processing request")
        elif log_type == 2:
            logger.warning(f"Warning message #{counter}: Resource usage at 75%")
        elif log_type == 3:
            logger.error(f"Error message #{counter}: Failed to connect to database")
        elif log_type == 4:
            logger.critical(f"Critical message #{counter}: System failure detected!")
        
        # Random sleep between 2-5 seconds
        sleep_time = random.uniform(2, 5)
        time.sleep(sleep_time)

if __name__ == "__main__":
    main()
