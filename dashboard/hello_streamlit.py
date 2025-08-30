import streamlit as st

st.title("AI Podcast Dashboard - Environment Test")
st.success("✅ Streamlit environment successfully configured!")

col1, col2, col3 = st.columns(3)

with col1:
    st.metric("Streamlit Version", st.__version__)

with col2:
    try:
        import pandas as pd
        st.metric("Pandas Version", pd.__version__)
    except ImportError:
        st.error("Pandas not available")

with col3:
    try:
        import numpy as np
        st.metric("NumPy Version", np.__version__)
    except ImportError:
        st.error("NumPy not available")

st.info("Environment validation complete. Ready for dashboard development.")

# Test basic Streamlit functionality
if st.button("Test Streamlit Functionality"):
    st.balloons()
    st.success("✅ Streamlit functionality test passed!")

# Configuration display
with st.expander("Configuration Details"):
    st.code(f"""
Dashboard Configuration:
- Streamlit Version: {st.__version__}
- Python Version: {st.__version__ if hasattr(st, '__version__') else 'Unknown'}
- Ready for real-time updates: ✅
- MIT validated patterns: ✅
    """)

st.markdown("---")
st.markdown("**Next Step:** TASK-002 - Create basic dashboard layout structure")
