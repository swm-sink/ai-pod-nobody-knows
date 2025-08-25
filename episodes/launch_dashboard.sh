#!/bin/bash

# Launch Nobody Knows Podcast Dashboard

echo "🎙️ Nobody Knows Podcast Dashboard"
echo "================================="

# Check if we're in the episodes directory
if [ ! -f "state.json" ]; then
    echo "❌ Error: Must run from episodes directory"
    echo "   Navigate to the episodes directory first"
    exit 1
fi

# Check if Streamlit is installed
if ! command -v streamlit &> /dev/null; then
    echo "❌ Streamlit not found. Installing..."
    pip install streamlit pandas
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install Streamlit"
        exit 1
    fi
fi

echo "🚀 Starting dashboard..."
echo "   URL: http://localhost:8501"
echo "   Press Ctrl+C to stop"
echo

# Launch Streamlit dashboard
streamlit run dashboard.py --server.port 8501 --server.headless true
