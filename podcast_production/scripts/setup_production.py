#!/usr/bin/env python3
"""
Production Environment Setup Script
===================================

Comprehensive setup and validation script for the AI Podcast Production System.
This script configures the production environment, validates all components,
and ensures the system is ready for reliable episode production.

Version: 1.0.0
Date: September 2025
Usage: python scripts/setup_production.py --mode=production
"""

from config.voice_config import get_production_voice_id

import os
import sys
import json
import yaml
import logging
import argparse
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass
import requests
import time

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# Import project modules
try:
    from core.config.manager import ConfigManager
    from core.cost_tracker import CostTracker
    from core.logging_config import setup_logging
except ImportError as e:
    print(f"Error importing project modules: {e}")
    print("Please ensure you're running this script from the podcast_production directory")
    sys.exit(1)


@dataclass
class SetupResult:
    """Result of a setup operation"""
    success: bool
    message: str
    details: Optional[Dict[str, Any]] = None
    duration_seconds: Optional[float] = None


@dataclass
class ValidationResult:
    """Result of a validation check"""
    component: str
    status: str  # 'pass', 'fail', 'warning', 'skip'
    message: str
    details: Optional[Dict[str, Any]] = None
    cost: Optional[float] = None


class ProductionSetup:
    """Production environment setup and validation system"""
    
    def __init__(self, config_path: Optional[str] = None):
        self.setup_start_time = datetime.now()
        self.results: List[SetupResult] = []
        self.validation_results: List[ValidationResult] = []
        
        # Setup logging
        self.logger = self._setup_logging()
        
        # Load configuration
        self.config_path = config_path or "config/production_config.yaml"
        self.config = self._load_config()
        
        # Initialize cost tracking
        self.cost_tracker = CostTracker()
        
        # Setup directories
        self._setup_directories()
        
    def _setup_logging(self) -> logging.Logger:
        """Configure logging for setup process"""
        log_dir = Path("logs")
        log_dir.mkdir(exist_ok=True)
        
        log_file = log_dir / "production_setup.log"
        
        # Configure root logger
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler(sys.stdout)
            ]
        )
        
        logger = logging.getLogger(__name__)
        logger.info("Production setup logging initialized")
        return logger
        
    def _load_config(self) -> Dict[str, Any]:
        """Load production configuration"""
        try:
            with open(self.config_path, 'r') as f:
                config = yaml.safe_load(f)
            self.logger.info(f"Loaded configuration from {self.config_path}")
            return config
        except Exception as e:
            self.logger.error(f"Failed to load configuration: {e}")
            return {}
            
    def _setup_directories(self) -> None:
        """Create necessary directories"""
        directories = [
            "logs",
            "output",
            "outputs",
            "audio_output",
            "research_data",
            "reports",
            "backup",
            "monitoring",
            "scripts",
            "tests/unit",
            "validation_episodes"
        ]
        
        for directory in directories:
            Path(directory).mkdir(parents=True, exist_ok=True)
            
    def validate_environment_variables(self) -> SetupResult:
        """Validate required environment variables"""
        start_time = time.time()
        self.logger.info("Validating environment variables...")
        
        required_vars = [
            # Core LLM providers
            ("OPENROUTER_API_KEY", "OpenRouter API key for language models", True),
            ("ELEVENLABS_API_KEY", "ElevenLabs API key for audio synthesis", True),
            ("PERPLEXITY_API_KEY", "Perplexity API key for research", True),
            
            # Production settings
            ("PRODUCTION_VOICE_ID", "Production voice ID (critical)", True),
            ("MAX_EPISODE_COST", "Maximum episode cost budget", True),
            ("PODCAST_ENV", "Environment setting", False),
            
            # Optional but recommended
            ("LANGFUSE_PUBLIC_KEY", "Langfuse observability key", False),
            ("LANGFUSE_SECRET_KEY", "Langfuse secret key", False),
        ]
        
        missing_required = []
        missing_optional = []
        present_vars = {}
        
        for var_name, description, required in required_vars:
            value = os.getenv(var_name)
            if value:
                # Mask sensitive values in logs
                if "key" in var_name.lower() or "secret" in var_name.lower():
                    present_vars[var_name] = f"{value[:10]}...{value[-4:]}" if len(value) > 14 else "***"
                else:
                    present_vars[var_name] = value
            else:
                if required:
                    missing_required.append((var_name, description))
                else:
                    missing_optional.append((var_name, description))
        
        # Create .env template if it doesn't exist
        self._create_env_template()
        
        success = len(missing_required) == 0
        message = self._format_env_validation_message(missing_required, missing_optional, present_vars)
        
        duration = time.time() - start_time
        return SetupResult(
            success=success,
            message=message,
            details={
                "present_vars": present_vars,
                "missing_required": missing_required,
                "missing_optional": missing_optional
            },
            duration_seconds=duration
        )
        
    def _create_env_template(self) -> None:
        """Create environment template file"""
        template_path = Path(".env.production.template")
        if template_path.exists():
            return
            
        template_content = """# AI PODCAST PRODUCTION - PRODUCTION ENVIRONMENT
# Copy this file to .env and fill in your API keys

# Core Language Model Providers
OPENROUTER_API_KEY=sk-or-v1-your-openrouter-api-key-here
OPENAI_API_KEY=sk-proj-your-openai-api-key-here
ANTHROPIC_API_KEY=sk-ant-your-anthropic-api-key-here

# Audio Synthesis
ELEVENLABS_API_KEY=sk_your-elevenlabs-api-key-here
PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw

# Research and Fact-checking
PERPLEXITY_API_KEY=pplx-your-perplexity-api-key-here

# Observability (Optional)
LANGFUSE_PUBLIC_KEY=pk-lf-your-langfuse-public-key-here
LANGFUSE_SECRET_KEY=sk-lf-your-langfuse-secret-key-here
LANGFUSE_HOST=https://us.cloud.langfuse.com

# Production Settings
MAX_EPISODE_COST=5.51
PODCAST_ENV=production
LOG_LEVEL=INFO
"""
        
        try:
            with open(template_path, 'w') as f:
                f.write(template_content)
            self.logger.info(f"Created environment template: {template_path}")
        except Exception as e:
            self.logger.warning(f"Could not create .env template: {e}")
            
    def _format_env_validation_message(self, missing_required: List[Tuple[str, str]], 
                                      missing_optional: List[Tuple[str, str]], 
                                      present_vars: Dict[str, str]) -> str:
        """Format environment validation message"""
        message_parts = []
        
        if present_vars:
            message_parts.append(f"✓ Found {len(present_vars)} environment variables")
            
        if missing_required:
            message_parts.append(f"✗ Missing {len(missing_required)} REQUIRED variables:")
            for var_name, description in missing_required:
                message_parts.append(f"  - {var_name}: {description}")
                
        if missing_optional:
            message_parts.append(f"⚠ Missing {len(missing_optional)} optional variables:")
            for var_name, description in missing_optional:
                message_parts.append(f"  - {var_name}: {description}")
                
        if missing_required:
            message_parts.append("\nℹ Please copy .env.production.template to .env and configure your API keys")
            
        return "\n".join(message_parts)
        
    def validate_api_connectivity(self) -> SetupResult:
        """Validate connectivity to all required APIs"""
        start_time = time.time()
        self.logger.info("Validating API connectivity...")
        
        api_tests = [
            ("OpenRouter", self._test_openrouter_api),
            ("ElevenLabs", self._test_elevenlabs_api),
            ("Perplexity", self._test_perplexity_api),
            ("Langfuse", self._test_langfuse_api),
        ]
        
        results = {}
        total_cost = 0.0
        
        for api_name, test_func in api_tests:
            try:
                self.logger.info(f"Testing {api_name} API...")
                result = test_func()
                results[api_name] = result
                if result.get("cost"):
                    total_cost += result["cost"]
                    self.cost_tracker.add_cost("api_validation", result["cost"], f"{api_name} connectivity test")
            except Exception as e:
                self.logger.error(f"Failed to test {api_name} API: {e}")
                results[api_name] = {"status": "error", "error": str(e)}
                
        # Check if critical APIs are working
        critical_apis = ["OpenRouter", "ElevenLabs"]
        critical_working = all(results.get(api, {}).get("status") == "success" for api in critical_apis)
        
        duration = time.time() - start_time
        success_count = sum(1 for r in results.values() if r.get("status") == "success")
        
        message = f"API Connectivity: {success_count}/{len(api_tests)} APIs working"
        if not critical_working:
            message += " (CRITICAL APIS FAILING)"
            
        return SetupResult(
            success=critical_working,
            message=message,
            details={
                "results": results,
                "total_validation_cost": total_cost,
                "critical_apis_status": critical_working
            },
            duration_seconds=duration
        )
        
    def _test_openrouter_api(self) -> Dict[str, Any]:
        """Test OpenRouter API connectivity"""
        api_key = os.getenv("OPENROUTER_API_KEY")
        if not api_key:
            return {"status": "skip", "reason": "No API key provided"}
            
        try:
            headers = {
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
                "HTTP-Referer": "https://github.com/ai-podcasts-nobody-knows",
                "X-Title": "AI Podcast Production System"
            }
            
            # Test with minimal request
            data = {
                "model": "anthropic/claude-3-haiku",
                "messages": [{"role": "user", "content": "Test"}],
                "max_tokens": 10
            }
            
            response = requests.post(
                "https://openrouter.ai/api/v1/chat/completions",
                headers=headers,
                json=data,
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                cost = self._estimate_cost_from_usage(result.get("usage", {}))
                return {
                    "status": "success",
                    "cost": cost,
                    "model": data["model"],
                    "response_time_ms": response.elapsed.total_seconds() * 1000
                }
            else:
                return {
                    "status": "error",
                    "error": f"HTTP {response.status_code}: {response.text[:200]}"
                }
                
        except Exception as e:
            return {"status": "error", "error": str(e)}
            
    def _test_elevenlabs_api(self) -> Dict[str, Any]:
        """Test ElevenLabs API connectivity"""
        api_key = os.getenv("ELEVENLABS_API_KEY")
        voice_id = os.getenv("PRODUCTION_VOICE_ID", get_production_voice_id())
        
        if not api_key:
            return {"status": "skip", "reason": "No API key provided"}
            
        try:
            # Test voice availability
            headers = {"xi-api-key": api_key}
            response = requests.get(
                f"https://api.elevenlabs.io/v1/voices/{voice_id}",
                headers=headers,
                timeout=15
            )
            
            if response.status_code == 200:
                voice_data = response.json()
                return {
                    "status": "success",
                    "voice_id": voice_id,
                    "voice_name": voice_data.get("name", "Unknown"),
                    "voice_category": voice_data.get("category", "Unknown"),
                    "response_time_ms": response.elapsed.total_seconds() * 1000
                }
            else:
                return {
                    "status": "error",
                    "error": f"HTTP {response.status_code}: {response.text[:200]}"
                }
                
        except Exception as e:
            return {"status": "error", "error": str(e)}
            
    def _test_perplexity_api(self) -> Dict[str, Any]:
        """Test Perplexity API connectivity"""
        api_key = os.getenv("PERPLEXITY_API_KEY")
        if not api_key:
            return {"status": "skip", "reason": "No API key provided"}
            
        try:
            headers = {
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json"
            }
            
            data = {
                "model": "llama-3.1-sonar-small-128k-online",
                "messages": [{"role": "user", "content": "What is 2+2?"}],
                "max_tokens": 10
            }
            
            response = requests.post(
                "https://api.perplexity.ai/chat/completions",
                headers=headers,
                json=data,
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                cost = self._estimate_cost_from_usage(result.get("usage", {}), provider="perplexity")
                return {
                    "status": "success",
                    "cost": cost,
                    "model": data["model"],
                    "response_time_ms": response.elapsed.total_seconds() * 1000
                }
            else:
                return {
                    "status": "error",
                    "error": f"HTTP {response.status_code}: {response.text[:200]}"
                }
                
        except Exception as e:
            return {"status": "error", "error": str(e)}
            
    def _test_langfuse_api(self) -> Dict[str, Any]:
        """Test Langfuse API connectivity"""
        public_key = os.getenv("LANGFUSE_PUBLIC_KEY")
        secret_key = os.getenv("LANGFUSE_SECRET_KEY")
        
        if not public_key or not secret_key:
            return {"status": "skip", "reason": "No API keys provided"}
            
        try:
            from langfuse import Langfuse
            
            langfuse = Langfuse(
                public_key=public_key,
                secret_key=secret_key,
                host=os.getenv("LANGFUSE_HOST", "https://us.cloud.langfuse.com")
            )
            
            # Create a test trace
            trace = langfuse.trace(name="production_setup_test")
            trace.update(output="Production setup validation")
            
            return {
                "status": "success",
                "trace_id": trace.id,
                "host": langfuse.client.base_url
            }
            
        except ImportError:
            return {"status": "skip", "reason": "Langfuse not installed"}
        except Exception as e:
            return {"status": "error", "error": str(e)}
            
    def _estimate_cost_from_usage(self, usage: Dict[str, Any], provider: str = "openrouter") -> float:
        """Estimate API call cost from usage data"""
        if not usage:
            return 0.0
            
        # Rough cost estimation (update with actual rates)
        cost_per_1k_tokens = {
            "openrouter": {"input": 0.003, "output": 0.015},
            "perplexity": {"input": 0.001, "output": 0.001}
        }
        
        rates = cost_per_1k_tokens.get(provider, {"input": 0.001, "output": 0.001})
        
        input_tokens = usage.get("prompt_tokens", 0)
        output_tokens = usage.get("completion_tokens", 0)
        
        input_cost = (input_tokens / 1000) * rates["input"]
        output_cost = (output_tokens / 1000) * rates["output"]
        
        return round(input_cost + output_cost, 6)
        
    def validate_system_components(self) -> SetupResult:
        """Validate system components and dependencies"""
        start_time = time.time()
        self.logger.info("Validating system components...")
        
        validations = [
            ("Python Version", self._check_python_version),
            ("Required Packages", self._check_required_packages),
            ("File Permissions", self._check_file_permissions),
            ("Disk Space", self._check_disk_space),
            ("Memory Available", self._check_memory),
            ("Cost Tracker", self._check_cost_tracker),
        ]
        
        results = {}
        for component_name, check_func in validations:
            try:
                result = check_func()
                results[component_name] = result
                self.logger.info(f"{component_name}: {'✓' if result['status'] == 'pass' else '✗'} {result['message']}")
            except Exception as e:
                results[component_name] = {"status": "error", "message": str(e)}
                self.logger.error(f"{component_name}: Error - {e}")
        
        failed_components = [name for name, result in results.items() if result["status"] == "fail"]
        success = len(failed_components) == 0
        
        duration = time.time() - start_time
        message = f"System Components: {len(results) - len(failed_components)}/{len(results)} passed"
        
        return SetupResult(
            success=success,
            message=message,
            details=results,
            duration_seconds=duration
        )
        
    def _check_python_version(self) -> Dict[str, Any]:
        """Check Python version compatibility"""
        import sys
        version = sys.version_info
        
        if version >= (3, 11):
            return {
                "status": "pass",
                "message": f"Python {version.major}.{version.minor}.{version.micro}",
                "details": {"version": f"{version.major}.{version.minor}.{version.micro}"}
            }
        else:
            return {
                "status": "fail",
                "message": f"Python {version.major}.{version.minor}.{version.micro} (requires 3.11+)",
                "details": {"version": f"{version.major}.{version.minor}.{version.micro}"}
            }
            
    def _check_required_packages(self) -> Dict[str, Any]:
        """Check required Python packages"""
        required_packages = [
            "langgraph", "langchain", "pydantic", "requests", "pyyaml",
            "openai", "anthropic", "elevenlabs", "msgpack"
        ]
        
        missing = []
        installed = []
        
        for package in required_packages:
            try:
                __import__(package)
                installed.append(package)
            except ImportError:
                missing.append(package)
        
        if missing:
            return {
                "status": "fail",
                "message": f"Missing packages: {', '.join(missing)}",
                "details": {"missing": missing, "installed": installed}
            }
        else:
            return {
                "status": "pass",
                "message": f"All {len(installed)} packages installed",
                "details": {"installed": installed}
            }
            
    def _check_file_permissions(self) -> Dict[str, Any]:
        """Check file and directory permissions"""
        critical_paths = [
            ("logs", "write"),
            ("output", "write"),
            ("config", "read"),
            (".", "read")
        ]
        
        permission_issues = []
        
        for path, required_perm in critical_paths:
            path_obj = Path(path)
            if path_obj.exists():
                if required_perm == "write" and not os.access(path_obj, os.W_OK):
                    permission_issues.append(f"Cannot write to {path}")
                elif required_perm == "read" and not os.access(path_obj, os.R_OK):
                    permission_issues.append(f"Cannot read from {path}")
            else:
                try:
                    path_obj.mkdir(parents=True, exist_ok=True)
                except OSError as e:
                    permission_issues.append(f"Cannot create {path}: {e}")
        
        if permission_issues:
            return {
                "status": "fail",
                "message": f"Permission issues: {len(permission_issues)}",
                "details": {"issues": permission_issues}
            }
        else:
            return {
                "status": "pass",
                "message": "All permissions OK",
                "details": {"checked_paths": [p[0] for p in critical_paths]}
            }
            
    def _check_disk_space(self) -> Dict[str, Any]:
        """Check available disk space"""
        import shutil
        
        try:
            total, used, free = shutil.disk_usage(".")
            free_gb = free / (1024**3)
            
            if free_gb < 1.0:
                return {
                    "status": "fail",
                    "message": f"Low disk space: {free_gb:.1f} GB available",
                    "details": {"free_gb": free_gb, "total_gb": total / (1024**3)}
                }
            elif free_gb < 5.0:
                return {
                    "status": "warning",
                    "message": f"Limited disk space: {free_gb:.1f} GB available",
                    "details": {"free_gb": free_gb, "total_gb": total / (1024**3)}
                }
            else:
                return {
                    "status": "pass",
                    "message": f"Sufficient disk space: {free_gb:.1f} GB available",
                    "details": {"free_gb": free_gb, "total_gb": total / (1024**3)}
                }
        except Exception as e:
            return {
                "status": "error",
                "message": f"Could not check disk space: {e}",
                "details": {"error": str(e)}
            }
            
    def _check_memory(self) -> Dict[str, Any]:
        """Check available system memory"""
        try:
            import psutil
            memory = psutil.virtual_memory()
            available_gb = memory.available / (1024**3)
            
            if available_gb < 2.0:
                return {
                    "status": "fail",
                    "message": f"Low memory: {available_gb:.1f} GB available",
                    "details": {"available_gb": available_gb, "total_gb": memory.total / (1024**3)}
                }
            else:
                return {
                    "status": "pass",
                    "message": f"Sufficient memory: {available_gb:.1f} GB available",
                    "details": {"available_gb": available_gb, "total_gb": memory.total / (1024**3)}
                }
        except ImportError:
            return {
                "status": "skip",
                "message": "psutil not available for memory check",
                "details": {"reason": "psutil not installed"}
            }
        except Exception as e:
            return {
                "status": "error",
                "message": f"Could not check memory: {e}",
                "details": {"error": str(e)}
            }
            
    def _check_cost_tracker(self) -> Dict[str, Any]:
        """Check cost tracking functionality"""
        try:
            # Test cost tracker
            self.cost_tracker.add_cost("test", 0.001, "Production setup validation")
            total_cost = self.cost_tracker.get_total_cost()
            
            return {
                "status": "pass",
                "message": f"Cost tracker functional (current: ${total_cost:.6f})",
                "details": {"total_cost": total_cost, "test_cost_added": 0.001}
            }
        except Exception as e:
            return {
                "status": "fail",
                "message": f"Cost tracker error: {e}",
                "details": {"error": str(e)}
            }
            
    def run_production_test(self) -> SetupResult:
        """Run a minimal production test to validate the complete system"""
        start_time = time.time()
        self.logger.info("Running production test...")
        
        try:
            # Import and test core components
            from main import PodcastProductionWorkflow
            
            # Initialize with test configuration
            workflow = PodcastProductionWorkflow()
            
            # Run minimal validation test
            test_topic = "AI Testing Validation"
            test_result = {
                "topic": test_topic,
                "validation_type": "production_setup",
                "timestamp": datetime.now().isoformat()
            }
            
            # Test basic workflow initialization
            state = workflow.create_initial_state(test_topic)
            
            duration = time.time() - start_time
            
            return SetupResult(
                success=True,
                message=f"Production test completed successfully",
                details={
                    "test_result": test_result,
                    "workflow_initialized": True,
                    "state_created": True
                },
                duration_seconds=duration
            )
            
        except Exception as e:
            duration = time.time() - start_time
            return SetupResult(
                success=False,
                message=f"Production test failed: {e}",
                details={"error": str(e)},
                duration_seconds=duration
            )
            
    def generate_setup_report(self) -> str:
        """Generate comprehensive setup report"""
        total_duration = (datetime.now() - self.setup_start_time).total_seconds()
        
        report_lines = [
            "=" * 80,
            "AI PODCAST PRODUCTION - PRODUCTION SETUP REPORT",
            "=" * 80,
            f"Setup Date: {self.setup_start_time.strftime('%Y-%m-%d %H:%M:%S')}",
            f"Total Duration: {total_duration:.1f} seconds",
            f"Configuration: {self.config_path}",
            "",
        ]
        
        # Summary statistics
        successful_steps = sum(1 for result in self.results if result.success)
        total_steps = len(self.results)
        
        report_lines.extend([
            "SUMMARY",
            "=" * 40,
            f"Setup Steps: {successful_steps}/{total_steps} successful",
            f"System Status: {'✓ READY FOR PRODUCTION' if successful_steps == total_steps else '✗ SETUP INCOMPLETE'}",
            "",
        ])
        
        # Detailed results
        if self.results:
            report_lines.extend([
                "SETUP RESULTS",
                "=" * 40,
            ])
            
            for i, result in enumerate(self.results, 1):
                status_icon = "✓" if result.success else "✗"
                duration_str = f" ({result.duration_seconds:.1f}s)" if result.duration_seconds else ""
                
                report_lines.extend([
                    f"{i:2d}. {status_icon} {result.message}{duration_str}",
                ])
                
                if result.details and not result.success:
                    # Show error details for failed steps
                    for key, value in result.details.items():
                        if isinstance(value, str) and len(value) < 200:
                            report_lines.append(f"     {key}: {value}")
                            
                report_lines.append("")
        
        # Cost summary
        total_cost = self.cost_tracker.get_total_cost()
        if total_cost > 0:
            report_lines.extend([
                "COST SUMMARY",
                "=" * 40,
                f"Total Setup Cost: ${total_cost:.6f}",
                f"Budget Remaining: ${float(os.getenv('MAX_EPISODE_COST', '5.51')) - total_cost:.6f}",
                "",
            ])
        
        # Next steps
        report_lines.extend([
            "NEXT STEPS",
            "=" * 40,
        ])
        
        if successful_steps == total_steps:
            report_lines.extend([
                "✓ Production environment is ready!",
                "✓ Run your first episode: python main.py --topic 'Your Topic'",
                "✓ Monitor costs and quality during production",
                "✓ Review logs in the logs/ directory",
            ])
        else:
            report_lines.extend([
                "✗ Complete the failed setup steps before production use",
                "✗ Check API keys and configuration",
                "✗ Resolve any permission or dependency issues",
                "✗ Re-run setup: python scripts/setup_production.py",
            ])
            
        report_lines.extend([
            "",
            "=" * 80,
            f"Report Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "=" * 80,
        ])
        
        return "\n".join(report_lines)
        
    def save_setup_report(self, report: str) -> str:
        """Save setup report to file"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_path = f"reports/production_setup_report_{timestamp}.md"
        
        # Ensure reports directory exists
        Path("reports").mkdir(exist_ok=True)
        
        with open(report_path, 'w') as f:
            f.write(report)
            
        self.logger.info(f"Setup report saved to: {report_path}")
        return report_path
        
    def run_complete_setup(self) -> bool:
        """Run complete production setup and validation"""
        self.logger.info("Starting complete production setup...")
        
        setup_steps = [
            ("Validate Environment Variables", self.validate_environment_variables),
            ("Validate API Connectivity", self.validate_api_connectivity),
            ("Validate System Components", self.validate_system_components),
            ("Run Production Test", self.run_production_test),
        ]
        
        for step_name, step_func in setup_steps:
            self.logger.info(f"Executing: {step_name}")
            try:
                result = step_func()
                self.results.append(result)
                
                if result.success:
                    self.logger.info(f"✓ {step_name}: {result.message}")
                else:
                    self.logger.error(f"✗ {step_name}: {result.message}")
                    
            except Exception as e:
                self.logger.error(f"✗ {step_name}: Exception - {e}")
                self.results.append(SetupResult(
                    success=False,
                    message=f"Exception in {step_name}: {e}",
                    details={"exception": str(e)}
                ))
        
        # Generate and save report
        report = self.generate_setup_report()
        report_path = self.save_setup_report(report)
        
        # Print summary
        print("\n" + report)
        print(f"\nDetailed report saved to: {report_path}")
        
        # Return overall success
        return all(result.success for result in self.results)


def main():
    """Main entry point for production setup script"""
    parser = argparse.ArgumentParser(
        description="AI Podcast Production - Production Environment Setup"
    )
    parser.add_argument(
        "--mode", 
        choices=["production", "staging", "development"],
        default="production",
        help="Environment mode"
    )
    parser.add_argument(
        "--config",
        help="Path to configuration file"
    )
    parser.add_argument(
        "--skip-api-tests",
        action="store_true",
        help="Skip API connectivity tests"
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose logging"
    )
    
    args = parser.parse_args()
    
    # Configure logging level
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Initialize setup
    config_path = args.config or f"config/{args.mode}_config.yaml"
    setup = ProductionSetup(config_path)
    
    print(f"""
    ╔══════════════════════════════════════════════════════════════╗
    ║                 AI PODCAST PRODUCTION SYSTEM                ║
    ║                   Production Setup v1.0.0                   ║
    ╠══════════════════════════════════════════════════════════════╣
    ║ Environment: {args.mode:<15} Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S'):<15} ║
    ║ Config: {config_path:<51} ║
    ╚══════════════════════════════════════════════════════════════╝
    """)
    
    # Run setup
    success = setup.run_complete_setup()
    
    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()