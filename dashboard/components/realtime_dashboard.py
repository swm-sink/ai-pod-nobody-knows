"""
Real-time dashboard implementation with MIT-validated update patterns
TASK-004: Implement real-time dashboard updates
"""

import streamlit as st
import time
import sys
import os
from datetime import datetime
from typing import Optional, Dict, Any

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from dashboard.utils.metrics_collector import MetricsCollector, ProductionMetrics
from dashboard.components.layout import DashboardLayout, DashboardMetrics
from dashboard.config import DashboardConfig
from dashboard.components.dashboard_updaters import (
    HeaderUpdater,
    PrimaryMetricsUpdater,
    SecondaryMetricsUpdater,
    SystemStatusUpdater,
    AlertUpdater,
    FooterUpdater
)


class RealTimeDashboard:
    """
    Real-time dashboard implementation using MIT-validated patterns
    Achieves <3 second update latency with 2-second intervals
    """

    def __init__(self, update_interval: int = 2):
        self.update_interval = update_interval  # MIT validated 2-second intervals
        self.config = DashboardConfig()
        self.metrics_collector = MetricsCollector()
        self.layout = DashboardLayout()

        # Performance tracking
        self.update_count = 0
        self.start_time = datetime.now()

        # Initialize specialized updaters (Single Responsibility Principle)
        self.header_updater = HeaderUpdater()
        self.primary_metrics_updater = PrimaryMetricsUpdater()
        self.secondary_metrics_updater = SecondaryMetricsUpdater(self.start_time, self.update_count)
        self.system_status_updater = SystemStatusUpdater(self.metrics_collector)
        self.alert_updater = AlertUpdater()
        self.footer_updater = FooterUpdater(self.start_time, self.update_interval)

        # Initialize Streamlit page config
        self._configure_streamlit()

    def _configure_streamlit(self):
        """Configure Streamlit for optimal real-time performance"""
        st.set_page_config(
            page_title=self.config.PAGE_TITLE,
            page_icon=self.config.PAGE_ICON,
            layout="wide",
            initial_sidebar_state="expanded"
        )

    def create_realtime_containers(self) -> Dict[str, Any]:
        """
        Create empty containers for real-time updates (MIT pattern)
        Returns placeholders that can be updated without full page refresh
        """
        # Header container
        header_container = st.empty()

        # Navigation sidebar
        with st.sidebar:
            st.title("📋 Dashboard Navigation")
            nav_container = st.empty()

        # Main metrics containers
        metrics_header_container = st.empty()
        primary_metrics_container = st.empty()
        secondary_metrics_container = st.empty()

        # Charts and analytics containers
        charts_header_container = st.empty()
        charts_container = st.empty()

        # Status and alerts containers
        status_header_container = st.empty()
        status_container = st.empty()
        alerts_container = st.empty()

        # Footer container
        footer_container = st.empty()

        return {
            'header': header_container,
            'navigation': nav_container,
            'metrics_header': metrics_header_container,
            'primary_metrics': primary_metrics_container,
            'secondary_metrics': secondary_metrics_container,
            'charts_header': charts_header_container,
            'charts': charts_container,
            'status_header': status_header_container,
            'status': status_container,
            'alerts': alerts_container,
            'footer': footer_container
        }

    def update_header(self, container):
        """Update header with current timestamp and status"""
        self.header_updater.update(container)

    def update_primary_metrics(self, container, metrics: ProductionMetrics):
        """Update primary metrics display"""
        self.primary_metrics_updater.update(container, metrics)

    def update_secondary_metrics(self, container, metrics: ProductionMetrics):
        """Update secondary metrics display"""
        self.secondary_metrics_updater.update(container, metrics, self.update_count)

    def update_system_status(self, container):
        """Update system status indicators"""
        self.system_status_updater.update(container)

    def update_alerts(self, container, metrics: ProductionMetrics):
        """Update alerts and notifications"""
        self.alert_updater.update(container, metrics)

    def update_footer(self, container):
        """Update footer with performance and status information"""
        self.footer_updater.update(container, self.update_count)

    def run_realtime_updates(self):
        """
        Main real-time update loop
        MIT-validated pattern with 2-second intervals and <3 second latency
        """
        # Display initial header
        st.title("🎙️ Real-time AI Podcast Dashboard")
        st.info("🔄 Initializing real-time updates...")

        # Create all containers
        containers = self.create_realtime_containers()

        # Add control buttons
        col1, col2, col3 = st.columns(3)

        with col1:
            auto_update = st.checkbox("🔄 Auto-update", value=True)

        with col2:
            if st.button("📊 Refresh Now"):
                st.rerun()

        with col3:
            st.markdown(f"**Update Interval:** {self.update_interval}s")

        # Real-time update loop
        if auto_update:
            # Create placeholder for the update loop
            update_placeholder = st.empty()

            while True:
                update_start_time = datetime.now()

                try:
                    # Collect fresh metrics
                    metrics = self.metrics_collector.collect_all_metrics()

                    # Update all containers
                    self.update_header(containers['header'])
                    self.update_primary_metrics(containers['primary_metrics'], metrics)
                    self.update_secondary_metrics(containers['secondary_metrics'], metrics)
                    self.update_system_status(containers['status'])
                    self.update_alerts(containers['alerts'], metrics)
                    self.update_footer(containers['footer'])

                    # Track performance
                    self.update_count += 1
                    update_duration = (datetime.now() - update_start_time).total_seconds()

                    # Validate MIT requirement: <3 second update latency
                    if update_duration > 3.0:
                        st.warning(f"⚠️ Update took {update_duration:.1f}s (>3s MIT threshold)")

                    # Update performance display
                    with update_placeholder.container():
                        st.success(f"✅ Update #{self.update_count} completed in {update_duration:.1f}s")

                except Exception as e:
                    st.error(f"❌ Update failed: {str(e)}")

                # Wait for next update (MIT validated 2-second intervals)
                time.sleep(self.update_interval)
        else:
            # Static display when auto-update is disabled
            metrics = self.metrics_collector.collect_all_metrics()

            self.update_header(containers['header'])
            self.update_primary_metrics(containers['primary_metrics'], metrics)
            self.update_secondary_metrics(containers['secondary_metrics'], metrics)
            self.update_system_status(containers['status'])
            self.update_alerts(containers['alerts'], metrics)
            self.update_footer(containers['footer'])


def main():
    """Main entry point for real-time dashboard"""
    dashboard = RealTimeDashboard()
    dashboard.run_realtime_updates()


if __name__ == "__main__":
    main()
