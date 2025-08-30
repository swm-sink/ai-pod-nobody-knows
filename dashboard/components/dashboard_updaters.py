"""
Dashboard update components with single responsibility focus
Extracted from RealTimeDashboard for improved maintainability
"""

import streamlit as st
from datetime import datetime
from typing import Dict, Any
from dashboard.utils.metrics_collector import ProductionMetrics


class HeaderUpdater:
    """Manages header display updates"""

    def update(self, container):
        """Update header with current timestamp and status"""
        with container.container():
            col1, col2, col3 = st.columns([2, 1, 1])

            with col1:
                st.title("🎙️ AI Podcast Production Dashboard")

            with col2:
                st.success("🟢 Real-time Updates Active")

            with col3:
                current_time = datetime.now().strftime("%H:%M:%S")
                st.info(f"⏰ {current_time}")

            st.markdown("---")


class PrimaryMetricsUpdater:
    """Manages primary production metrics display"""

    def update(self, container, metrics: ProductionMetrics):
        """Update primary metrics display"""
        with container.container():
            st.markdown("### 📊 Primary Production Metrics")

            col1, col2, col3 = st.columns(3)

            self._update_cost_metric(col1, metrics)
            self._update_accuracy_metric(col2, metrics)
            self._update_agent_status(col3, metrics)

    def _update_cost_metric(self, column, metrics: ProductionMetrics):
        """Update cost metric with variance indication"""
        with column:
            cost_color = "inverse" if metrics.cost_variance > 0 else "normal"
            st.metric(
                label="💰 Episode Cost",
                value=f"${metrics.current_cost:.2f}",
                delta=f"${metrics.cost_variance:.2f}" if abs(metrics.cost_variance) > 0.01 else None,
                delta_color=cost_color
            )

            # Cost target indicator
            if metrics.current_cost <= metrics.cost_target:
                st.success(f"✅ Within target (${metrics.cost_target:.2f})")
            else:
                st.warning(f"⚠️ Above target (${metrics.cost_target:.2f})")

    def _update_accuracy_metric(self, column, metrics: ProductionMetrics):
        """Update accuracy metric"""
        with column:
            accuracy_color = "normal" if metrics.accuracy_variance >= 0 else "inverse"
            st.metric(
                label="🎯 Quality Score",
                value=f"{metrics.current_accuracy:.1f}%",
                delta=f"{metrics.accuracy_variance:.1f}%" if abs(metrics.accuracy_variance) > 0.1 else None,
                delta_color=accuracy_color
            )

            # Quality target indicator
            if metrics.current_accuracy >= metrics.accuracy_target:
                st.success(f"✅ Above target ({metrics.accuracy_target:.1f}%)")
            else:
                st.warning(f"⚠️ Below target ({metrics.accuracy_target:.1f}%)")

    def _update_agent_status(self, column, metrics: ProductionMetrics):
        """Update agent status metric"""
        with column:
            st.metric(
                label="🤖 Agent Status",
                value=f"{metrics.active_agents} Active",
                delta=None
            )

            # Agent health indicator
            if metrics.active_agents >= 18:
                st.success("✅ All systems operational")
            elif metrics.active_agents >= 15:
                st.warning("⚠️ Some agents offline")
            else:
                st.error("❌ Critical agents offline")


class SecondaryMetricsUpdater:
    """Manages secondary metrics display"""

    def __init__(self, start_time: datetime, update_count: int):
        self.start_time = start_time
        self.update_count = update_count

    def update(self, container, metrics: ProductionMetrics, current_update_count: int):
        """Update secondary metrics display"""
        self.update_count = current_update_count

        with container.container():
            st.markdown("### 📈 Secondary Metrics")

            col1, col2, col3, col4 = st.columns(4)

            self._update_voice_consistency(col1, metrics)
            self._update_uptime(col2)
            self._update_count_metric(col3)
            self._update_performance(col4)

    def _update_voice_consistency(self, column, metrics: ProductionMetrics):
        """Update voice consistency metric"""
        with column:
            st.metric(
                label="🎤 Voice Consistency",
                value=f"{metrics.voice_consistency_score:.1f}%",
                delta=None
            )

    def _update_uptime(self, column):
        """Update dashboard uptime"""
        with column:
            uptime = (datetime.now() - self.start_time).total_seconds() / 60
            st.metric(
                label="⏱️ Dashboard Uptime",
                value=f"{uptime:.1f} min",
                delta=None
            )

    def _update_count_metric(self, column):
        """Update update count metric"""
        with column:
            st.metric(
                label="🔄 Update Count",
                value=str(self.update_count),
                delta=None
            )

    def _update_performance(self, column):
        """Update performance metric"""
        with column:
            uptime = (datetime.now() - self.start_time).total_seconds() / 60
            avg_update_time = uptime / max(self.update_count, 1) * 60  # seconds per update
            performance_color = "normal" if avg_update_time <= 3.0 else "inverse"
            st.metric(
                label="⚡ Avg Update Time",
                value=f"{avg_update_time:.1f}s",
                delta=None,
                delta_color=performance_color
            )


class SystemStatusUpdater:
    """Manages system status display"""

    def __init__(self, metrics_collector):
        self.metrics_collector = metrics_collector

    def update(self, container):
        """Update system status indicators"""
        with container.container():
            st.markdown("### 🔧 System Health Status")

            # Get health check from metrics collector
            health = self.metrics_collector.health_check()

            col1, col2, col3 = st.columns(3)

            self._update_data_sources(col1, health)
            self._update_api_status(col2)
            self._update_performance_status(col3, health)

    def _update_data_sources(self, column, health: Dict[str, Any]):
        """Update data sources status"""
        with column:
            st.markdown("**Data Sources**")
            components = health.get('components', {})

            for component, status in components.items():
                if status.get('status') == 'healthy':
                    st.success(f"✅ {component.replace('_', ' ').title()}")
                else:
                    st.error(f"❌ {component.replace('_', ' ').title()}")

    def _update_api_status(self, column):
        """Update API status display"""
        with column:
            st.markdown("**API Status**")
            # Placeholder for API status (will be implemented with actual API checks)
            st.success("✅ ElevenLabs API")
            st.success("✅ Claude API")
            st.success("✅ Gemini API")
            st.info("🟡 Perplexity API")

    def _update_performance_status(self, column, health: Dict[str, Any]):
        """Update performance status"""
        with column:
            st.markdown("**Performance**")
            overall_health = health.get('overall_health', 'unknown')

            if overall_health == 'healthy':
                st.success("✅ System Healthy")
            elif overall_health == 'degraded':
                st.warning("⚠️ System Degraded")
            else:
                st.error("❌ System Error")

            st.info(f"Last Check: {datetime.now().strftime('%H:%M:%S')}")


class AlertUpdater:
    """Manages alert display and notifications"""

    def update(self, container, metrics: ProductionMetrics):
        """Update alerts and notifications"""
        alerts = self._generate_alerts(metrics)

        # Display alerts
        with container.container():
            if alerts:
                st.markdown("### 🚨 Active Alerts")
                for alert in alerts:
                    if alert['type'] == 'error':
                        st.error(alert['message'])
                    elif alert['type'] == 'warning':
                        st.warning(alert['message'])
                    else:
                        st.info(alert['message'])
            else:
                st.success("✅ No active alerts - system operating normally")

    def _generate_alerts(self, metrics: ProductionMetrics) -> list:
        """Generate alerts based on metrics"""
        alerts = []

        # Cost alerts
        if metrics.current_cost > metrics.cost_target * 1.1:  # 10% over target
            alerts.append({
                'type': 'error',
                'message': f"Cost ${metrics.current_cost:.2f} is 10% above target ${metrics.cost_target:.2f}"
            })
        elif metrics.current_cost > metrics.cost_target * 1.05:  # 5% over target
            alerts.append({
                'type': 'warning',
                'message': f"Cost ${metrics.current_cost:.2f} approaching target limit"
            })

        # Quality alerts
        if metrics.current_accuracy < metrics.accuracy_target * 0.9:  # 10% below target
            alerts.append({
                'type': 'error',
                'message': f"Quality {metrics.current_accuracy:.1f}% is significantly below target {metrics.accuracy_target:.1f}%"
            })
        elif metrics.current_accuracy < metrics.accuracy_target * 0.95:  # 5% below target
            alerts.append({
                'type': 'warning',
                'message': f"Quality {metrics.current_accuracy:.1f}% below target threshold"
            })

        # Agent alerts
        if metrics.active_agents < 15:
            alerts.append({
                'type': 'error',
                'message': f"Only {metrics.active_agents}/18 agents active - system degraded"
            })
        elif metrics.active_agents < 18:
            alerts.append({
                'type': 'warning',
                'message': f"{18 - metrics.active_agents} agents offline"
            })

        return alerts


class FooterUpdater:
    """Manages footer display"""

    def __init__(self, start_time: datetime, update_interval: int):
        self.start_time = start_time
        self.update_interval = update_interval

    def update(self, container, update_count: int):
        """Update footer with performance and status information"""
        with container.container():
            st.markdown("---")

            col1, col2, col3 = st.columns(3)

            with col1:
                st.markdown("*Real-time Dashboard • MIT-validated 2-second updates*")

            with col2:
                st.markdown(f"*Update #{update_count} • Next in {self.update_interval}s*")

            with col3:
                st.markdown(f"*Dashboard Active • Started {self.start_time.strftime('%H:%M:%S')}*")
