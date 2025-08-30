"""
Basic environment validation tests for dashboard implementation
"""
import os
import pytest


def test_dashboard_structure_exists():
    """Test that dashboard directory structure is created"""
    assert os.path.exists("dashboard"), "Dashboard directory should exist"
    assert os.path.exists("dashboard/__init__.py"), "Dashboard __init__.py should exist"
    assert os.path.exists("dashboard/config.py"), "Dashboard config.py should exist"


def test_requirements_file_exists():
    """Test that requirements file is created"""
    assert os.path.exists("dashboard_requirements.txt"), "Requirements file should exist"

    # Check content
    with open("dashboard_requirements.txt", "r") as f:
        content = f.read()
        assert "streamlit>=1.28.0" in content
        assert "pandas>=1.5.0" in content


def test_hello_app_exists():
    """Test that hello world app is created"""
    assert os.path.exists("dashboard/hello_streamlit.py"), "Hello Streamlit app should exist"


def test_config_importable():
    """Test that dashboard config can be imported"""
    import sys
    import os

    # Add current directory to path for import
    current_dir = os.getcwd()
    if current_dir not in sys.path:
        sys.path.insert(0, current_dir)

    try:
        from dashboard.config import DashboardConfig
        config = DashboardConfig()
        assert config.STREAMLIT_PORT == 8501
        assert config.UPDATE_INTERVAL_SECONDS == 2
        print("✅ Dashboard config successfully imported and validated")
    except ImportError as e:
        pytest.fail(f"Dashboard config should be importable: {e}")


if __name__ == "__main__":
    # Run basic validation
    test_dashboard_structure_exists()
    test_requirements_file_exists()
    test_hello_app_exists()
    test_config_importable()
    print("✅ All environment tests passed!")
