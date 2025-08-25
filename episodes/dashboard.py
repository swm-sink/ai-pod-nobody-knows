#!/usr/bin/env python3
"""
Nobody Knows Podcast Dashboard
Real-time monitoring for episode production pipeline
"""

import streamlit as st
import json
import pandas as pd
from datetime import datetime
import time
import os
from pathlib import Path

# Configure Streamlit page
st.set_page_config(
    page_title="Nobody Knows Dashboard",
    page_icon="🎙️",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .metric-card {
        background-color: #f0f2f6;
        padding: 1rem;
        border-radius: 0.5rem;
        margin: 0.5rem 0;
    }
    .status-grid {
        display: grid;
        grid-template-columns: repeat(25, 1fr);
        gap: 2px;
        margin: 1rem 0;
    }
    .status-cell {
        width: 20px;
        height: 20px;
        border-radius: 3px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
    }
    .batch-info {
        background-color: #e1f5fe;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #2196f3;
    }
</style>
""", unsafe_allow_html=True)

def load_state():
    """Load the master state file"""
    try:
        with open('state.json', 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        st.error("❌ state.json not found. Make sure you're running from the episodes directory.")
        return None
    except json.JSONDecodeError:
        st.error("❌ Invalid JSON in state.json")
        return None

def count_episode_statuses():
    """Count episodes by status"""
    production_dir = Path('production')
    if not production_dir.exists():
        return {}

    status_counts = {
        'not_started': 0,
        'researching': 0,
        'researched': 0,
        'producing': 0,
        'validating': 0,
        'complete': 0,
        'failed': 0
    }

    for ep_dir in production_dir.glob('ep*'):
        status_file = ep_dir / 'status.json'
        if status_file.exists():
            try:
                with open(status_file) as f:
                    status_data = json.load(f)
                    status = status_data.get('status', 'not_started')
                    if status in status_counts:
                        status_counts[status] += 1
                    else:
                        status_counts['not_started'] += 1
            except:
                status_counts['not_started'] += 1
        else:
            status_counts['not_started'] += 1

    return status_counts

def load_episode_details():
    """Load detailed episode information"""
    episodes = []
    production_dir = Path('production')

    if not production_dir.exists():
        return pd.DataFrame()

    for i in range(1, 126):  # Episodes 1-125
        ep_num = f"{i:03d}"
        ep_dir = production_dir / f'ep{ep_num}'

        episode_data = {
            'Episode': f'ep{ep_num}',
            'Number': i,
            'Status': 'not_started',
            'Research_Cost': 0.0,
            'Quality_Score': 0.0,
            'Last_Updated': ''
        }

        # Load status
        status_file = ep_dir / 'status.json'
        if status_file.exists():
            try:
                with open(status_file) as f:
                    status_data = json.load(f)
                    episode_data['Status'] = status_data.get('status', 'not_started')
                    episode_data['Last_Updated'] = status_data.get('updated', '')
            except:
                pass

        # Load metrics
        metrics_file = ep_dir / 'metrics.json'
        if metrics_file.exists():
            try:
                with open(metrics_file) as f:
                    metrics_data = json.load(f)
                    episode_data['Research_Cost'] = metrics_data.get('research_cost', 0.0)
                    episode_data['Quality_Score'] = metrics_data.get('research_quality', 0.0)
            except:
                pass

        episodes.append(episode_data)

    return pd.DataFrame(episodes)

def get_status_icon(status):
    """Get emoji icon for status"""
    icons = {
        'not_started': '⚪',
        'researching': '🔵',
        'researched': '🟡',
        'producing': '🟠',
        'validating': '🟣',
        'complete': '🟢',
        'failed': '🔴'
    }
    return icons.get(status, '❓')

def main():
    """Main dashboard function"""

    # Header
    st.title("🎙️ Nobody Knows Podcast Dashboard")
    st.markdown("Real-time monitoring for episode production pipeline")

    # Auto-refresh mechanism
    placeholder = st.empty()

    with placeholder.container():
        # Load data
        state = load_state()
        if not state:
            st.stop()

        status_counts = count_episode_statuses()
        df_episodes = load_episode_details()

        # Main metrics
        col1, col2, col3, col4 = st.columns(4)

        with col1:
            researched = status_counts.get('researched', 0)
            st.metric(
                label="📚 Researched",
                value=f"{researched}/125",
                delta=f"{(researched/125*100):.1f}%" if researched > 0 else None
            )

        with col2:
            produced = status_counts.get('complete', 0)
            st.metric(
                label="🎬 Completed",
                value=f"{produced}/125",
                delta=f"{(produced/125*100):.1f}%" if produced > 0 else None
            )

        with col3:
            total_cost = df_episodes['Research_Cost'].sum()
            avg_cost = total_cost / max(researched, 1)
            st.metric(
                label="💰 Total Cost",
                value=f"${total_cost:.2f}",
                delta=f"Avg: ${avg_cost:.2f}"
            )

        with col4:
            avg_quality = df_episodes[df_episodes['Quality_Score'] > 0]['Quality_Score'].mean()
            quality_display = f"{avg_quality:.1f}%" if pd.notna(avg_quality) else "N/A"
            st.metric(
                label="⭐ Avg Quality",
                value=quality_display
            )

        # Progress bars
        st.subheader("📈 Progress Overview")

        research_progress = researched / 125
        complete_progress = produced / 125

        col1, col2 = st.columns(2)
        with col1:
            st.write("**Research Progress**")
            st.progress(research_progress, text=f"{researched}/125 episodes researched")

        with col2:
            st.write("**Production Progress**")
            st.progress(complete_progress, text=f"{produced}/125 episodes completed")

        # Status breakdown
        st.subheader("📊 Status Distribution")

        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.write(f"⚪ Not Started: **{status_counts.get('not_started', 0)}**")
            st.write(f"🔵 Researching: **{status_counts.get('researching', 0)}**")
        with col2:
            st.write(f"🟡 Researched: **{status_counts.get('researched', 0)}**")
            st.write(f"🟠 Producing: **{status_counts.get('producing', 0)}**")
        with col3:
            st.write(f"🟣 Validating: **{status_counts.get('validating', 0)}**")
            st.write(f"🟢 Complete: **{status_counts.get('complete', 0)}**")
        with col4:
            st.write(f"🔴 Failed: **{status_counts.get('failed', 0)}**")

        # Episode grid visualization
        st.subheader("🎯 Episode Status Grid")
        st.write("Visual overview of all 125 episodes (Episodes 1-25 in first row, 26-50 in second row, etc.)")

        # Create grid in rows of 25
        for row in range(5):  # 5 rows for 125 episodes
            cols = st.columns(25)
            for col_idx in range(25):
                episode_num = row * 25 + col_idx + 1
                if episode_num <= 125:
                    ep_data = df_episodes[df_episodes['Number'] == episode_num]
                    if not ep_data.empty:
                        status = ep_data.iloc[0]['Status']
                        icon = get_status_icon(status)
                        with cols[col_idx]:
                            st.write(f"{icon}")
                            st.caption(f"{episode_num}")

        # Current batch information
        batch_info = state.get('batch')
        if batch_info and batch_info.get('status') != 'completed':
            st.subheader("🔄 Current Batch Operation")

            batch_type = batch_info.get('type', 'unknown')
            start = batch_info.get('start', 0)
            end = batch_info.get('end', 0)
            current = batch_info.get('current', 0)
            status = batch_info.get('status', 'unknown')

            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("Batch Type", batch_type.title())
            with col2:
                st.metric("Range", f"{start}-{end}")
            with col3:
                st.metric("Current", f"{current}/{end}")

            if status == 'in_progress':
                progress = (current - start + 1) / (end - start + 1) if end > start else 0
                st.progress(progress, text=f"Processing episode {current}...")

        # Test episodes summary
        test_info = state.get('episodes', {}).get('test', {})
        if test_info:
            st.subheader("🧪 Test Episodes")

            col1, col2 = st.columns(2)
            with col1:
                for test_name, test_data in test_info.items():
                    st.write(f"✅ **{test_name.replace('_', ' ').title()}**")
                    st.write(f"   Status: {test_data.get('status', 'unknown')}")
                    if 'quality_scores' in test_data:
                        avg_quality = sum(test_data['quality_scores'].values()) / len(test_data['quality_scores'])
                        st.write(f"   Avg Quality: {avg_quality:.1f}%")

        # Recent activity (last 10 episodes with updates)
        st.subheader("📋 Recent Activity")

        recent_episodes = df_episodes[df_episodes['Last_Updated'] != ''].sort_values('Last_Updated', ascending=False).head(10)

        if not recent_episodes.empty:
            for _, episode in recent_episodes.iterrows():
                icon = get_status_icon(episode['Status'])
                st.write(f"{icon} **{episode['Episode']}** - {episode['Status']} - {episode['Last_Updated'][:10]}")
        else:
            st.write("No recent activity")

        # Footer with last update time
        st.markdown("---")
        st.caption(f"Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} | Auto-refresh: 5 seconds")

    # Auto-refresh every 5 seconds
    time.sleep(5)
    st.rerun()

if __name__ == "__main__":
    main()
