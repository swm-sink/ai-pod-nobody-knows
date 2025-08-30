"""Configuration settings for dashboard application"""

import os
from dataclasses import dataclass

@dataclass
class DashboardConfig:
    """Dashboard configuration settings"""

    # Streamlit Configuration
    STREAMLIT_PORT: int = 8501
    STREAMLIT_HOST: str = "localhost"
    UPDATE_INTERVAL_SECONDS: int = 2  # MIT validated 2-second intervals

    # Data Sources
    COST_TRACKING_LOG_PATH: str = os.getenv(
        "COST_TRACKING_LOG",
        ".claude/logs/cost_tracking.log"
    )
    QUALITY_METRICS_PATH: str = os.getenv(
        "QUALITY_METRICS_PATH",
        "sessions/current/quality_metrics.json"
    )
    AGENT_STATUS_ENDPOINT: str = os.getenv(
        "AGENT_STATUS_API",
        "http://localhost:8500/agent-status"
    )

    # Dashboard Appearance
    THEME: str = "light"
    PAGE_TITLE: str = "AI Podcast Production Dashboard"
    PAGE_ICON: str = "🎙️"

    @classmethod
    def validate_config(cls):
        """Validate configuration settings"""
        config = cls()
        issues = []

        # Validate paths exist or can be created
        log_dir = os.path.dirname(config.COST_TRACKING_LOG_PATH)
        if not os.path.exists(log_dir):
            try:
                os.makedirs(log_dir, exist_ok=True)
            except Exception as e:
                issues.append(f"Cannot create log directory: {e}")

        return issues
