"""
Logging configuration for the podcast production system.

Provides consistent logging setup across all components with appropriate
levels, formatting, and output destinations.

Version: 1.0.0
Date: August 2025
"""

import logging
import logging.handlers
from pathlib import Path
from typing import Optional
import sys
from datetime import datetime


def setup_logging(
    verbose: bool = False,
    log_dir: Optional[str] = None,
    component: str = "main"
) -> logging.Logger:
    """
    Setup logging configuration for the application.
    
    Args:
        verbose: Enable debug-level logging
        log_dir: Directory for log files (defaults to ./logs)
        component: Component name for logger
        
    Returns:
        Configured logger instance
    """
    
    # Determine log level
    level = logging.DEBUG if verbose else logging.INFO
    
    # Create log directory
    if log_dir is None:
        log_dir = Path("logs")
    else:
        log_dir = Path(log_dir)
    
    log_dir.mkdir(exist_ok=True)
    
    # Create formatter
    formatter = logging.Formatter(
        fmt='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    # Get or create logger
    logger = logging.getLogger(component)
    logger.setLevel(level)
    
    # Remove existing handlers to avoid duplicates
    for handler in logger.handlers[:]:
        logger.removeHandler(handler)
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(level)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # File handler - daily rotation
    date_str = datetime.now().strftime('%Y%m%d')
    log_file = log_dir / f"podcast_production_{date_str}.log"
    
    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(logging.DEBUG)  # Always debug to file
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    
    # Error file handler - separate file for errors
    error_file = log_dir / f"errors_{date_str}.log"
    error_handler = logging.FileHandler(error_file)
    error_handler.setLevel(logging.ERROR)
    error_handler.setFormatter(formatter)
    logger.addHandler(error_handler)
    
    # Reduce noise from external libraries
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("urllib3").setLevel(logging.WARNING)
    logging.getLogger("openai").setLevel(logging.WARNING)
    logging.getLogger("anthropic").setLevel(logging.WARNING)
    
    logger.info(f"Logging configured for {component} - Level: {logging.getLevelName(level)}")
    logger.debug(f"Log files: {log_file}, {error_file}")
    
    return logger


def get_logger(name: str) -> logging.Logger:
    """
    Get a logger with the specified name.
    
    Args:
        name: Logger name (typically __name__)
        
    Returns:
        Logger instance
    """
    return logging.getLogger(name)


class CostTrackingFilter(logging.Filter):
    """
    Logging filter to extract and track cost information.
    
    This filter can be added to handlers to automatically extract
    cost data from log messages for tracking and reporting.
    """
    
    def __init__(self):
        super().__init__()
        self.total_cost = 0.0
        self.cost_breakdown = {}
    
    def filter(self, record):
        """Filter and extract cost information."""
        message = record.getMessage()
        
        # Look for cost patterns in log messages
        if "cost:" in message.lower() or "$" in message:
            # Extract cost information
            # This would be implemented based on specific cost logging patterns
            pass
        
        return True  # Always allow the record through


def add_cost_tracking(logger: logging.Logger) -> CostTrackingFilter:
    """
    Add cost tracking to a logger.
    
    Args:
        logger: Logger to add cost tracking to
        
    Returns:
        The cost tracking filter for access to cost data
    """
    cost_filter = CostTrackingFilter()
    
    for handler in logger.handlers:
        handler.addFilter(cost_filter)
    
    return cost_filter