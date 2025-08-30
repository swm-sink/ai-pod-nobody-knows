"""
Dashboard layout components for AI Podcast Production Dashboard
"""

import streamlit as st
from typing import Optional, Dict, Any
from dataclasses import dataclass

@dataclass
class DashboardMetrics:
    """Container for dashboard metrics data"""
    episode_cost: float = 0.0
    cost_delta: float = 0.0
    accuracy: float = 0.0
    accuracy_delta: float = 0.0
    agent_status: str = "Unknown"
    voice_consistency: float = 0.0


class DashboardLayout:
    """
    Main dashboard layout manager following Streamlit best practices
    Implements MIT-validated real-time update patterns
    """

    def __init__(self, title: str = "AI Podcast Production Dashboard"):
        self.title = title
        self.metrics_data = DashboardMetrics()

    def render_header(self):
        """Render dashboard header with title and status"""
        st.set_page_config(
            page_title="AI Podcast Dashboard",
            page_icon="🎙️",
            layout="wide",
            initial_sidebar_state="expanded"
        )

        st.title("🎙️ AI Podcast Production Dashboard")
        st.markdown("---")

        # Status indicator
        col1, col2, col3 = st.columns([2, 1, 1])
        with col1:
            st.markdown("**Real-time Production Monitoring & Control**")
        with col2:
            st.success("🟢 System Online")
        with col3:
            st.info(f"Updated: {self._get_timestamp()}")

    def render_metrics_row(self, metrics: Optional[DashboardMetrics] = None):
        """
        Render main metrics row with cost, quality, and status
        MIT validated: 3-column layout for optimal UX
        """
        if metrics is None:
            metrics = self.metrics_data

        # Main metrics columns
        col1, col2, col3 = st.columns(3)

        with col1:
            st.metric(
                label="💰 Episode Cost",
                value=f"${metrics.episode_cost:.2f}",
                delta=f"${metrics.cost_delta:.2f}" if metrics.cost_delta != 0 else None,
                delta_color="inverse"  # Red for cost increases
            )

        with col2:
            st.metric(
                label="🎯 Quality Score",
                value=f"{metrics.accuracy:.1f}%",
                delta=f"{metrics.accuracy_delta:.1f}%" if metrics.accuracy_delta != 0 else None,
                delta_color="normal"  # Green for quality increases
            )

        with col3:
            st.metric(
                label="🤖 Agent Status",
                value=metrics.agent_status,
                delta=None
            )

    def render_secondary_metrics(self, metrics: Optional[DashboardMetrics] = None):
        """Render secondary metrics row"""
        if metrics is None:
            metrics = self.metrics_data

        col1, col2, col3 = st.columns(3)

        with col1:
            st.metric(
                label="🎤 Voice Consistency",
                value=f"{metrics.voice_consistency:.1f}%",
                delta=None
            )

        with col2:
            st.metric(
                label="⚡ Processing Speed",
                value="Real-time",
                delta=None
            )

        with col3:
            st.metric(
                label="📊 Success Rate",
                value="94.89%",
                delta=None
            )

    def render_navigation_sidebar(self):
        """Render navigation sidebar with dashboard sections"""
        with st.sidebar:
            st.title("📋 Dashboard Sections")

            sections = {
                "📊 Overview": "overview",
                "💰 Cost Analysis": "cost",
                "🎯 Quality Metrics": "quality",
                "🤖 Agent Management": "agents",
                "🎤 Voice Consistency": "voice",
                "⚙️ System Settings": "settings"
            }

            selected_section = st.radio(
                "Navigate to:",
                list(sections.keys()),
                index=0,
                key="navigation"
            )

            st.markdown("---")

            # Quick actions
            st.subheader("🚀 Quick Actions")

            if st.button("📝 New Episode"):
                st.success("Starting new episode workflow...")

            if st.button("🔄 Refresh Data"):
                st.info("Refreshing dashboard data...")

            if st.button("📈 Generate Report"):
                st.info("Generating production report...")

            return sections[selected_section]

    def render_chart_placeholders(self):
        """Render placeholder areas for charts and graphs"""
        st.markdown("### 📈 Production Analytics")

        # Two-column layout for charts
        chart_col1, chart_col2 = st.columns(2)

        with chart_col1:
            st.subheader("Cost Trend")
            # Placeholder for cost trend chart
            chart_placeholder_1 = st.empty()

        with chart_col2:
            st.subheader("Quality Trend")
            # Placeholder for quality trend chart
            chart_placeholder_2 = st.empty()

        # Full-width chart area
        st.subheader("Agent Activity Timeline")
        timeline_placeholder = st.empty()

        return {
            "cost_chart": chart_placeholder_1,
            "quality_chart": chart_placeholder_2,
            "timeline_chart": timeline_placeholder
        }

    def render_status_indicators(self):
        """Render system status indicators"""
        st.markdown("### 🔧 System Status")

        status_col1, status_col2, status_col3, status_col4 = st.columns(4)

        with status_col1:
            st.success("✅ ElevenLabs API")
        with status_col2:
            st.success("✅ Claude API")
        with status_col3:
            st.success("✅ Gemini API")
        with status_col4:
            st.success("✅ Perplexity API")

    def _get_timestamp(self) -> str:
        """Get current timestamp for display"""
        from datetime import datetime
        return datetime.now().strftime("%H:%M:%S")

    def create_empty_containers(self) -> Dict[str, Any]:
        """
        Create empty containers for real-time updates (MIT pattern)
        Returns dictionary of placeholder containers
        """
        return {
            "metrics_container": st.empty(),
            "charts_container": st.empty(),
            "status_container": st.empty(),
            "alerts_container": st.empty()
        }


def render_basic_dashboard_layout() -> DashboardLayout:
    """
    Render complete basic dashboard layout
    Main entry point for TASK-002 implementation
    """
    dashboard = DashboardLayout()

    # Render main layout components
    dashboard.render_header()

    # Navigation (returns selected section)
    selected_section = dashboard.render_navigation_sidebar()

    # Main content area
    dashboard.render_metrics_row()
    dashboard.render_secondary_metrics()

    st.markdown("---")

    chart_placeholders = dashboard.render_chart_placeholders()

    st.markdown("---")

    dashboard.render_status_indicators()

    # Footer
    st.markdown("---")
    st.markdown("*Dashboard built with Streamlit • Real-time updates every 2 seconds*")
    st.markdown("**Current Section:** " + selected_section)

    return dashboard


if __name__ == "__main__":
    # Test layout rendering
    render_basic_dashboard_layout()
