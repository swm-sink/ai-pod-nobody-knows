#!/usr/bin/env python3
"""
Health checking module for podcast production system.

Provides comprehensive health validation for production readiness.
Focuses on minimum viable complexity while ensuring system reliability.
"""

import os
import sys
import time
import psutil
import shutil
import logging
from datetime import datetime
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, asdict
from pathlib import Path

# Import our security and monitoring modules
try:
    from .security import validate_api_keys, validate_environment_security
    from .monitoring import create_simple_monitor
except ImportError:
    # Fallback for when running as standalone
    import sys
    sys.path.append('.')
    from security import validate_api_keys, validate_environment_security
    from monitoring import create_simple_monitor

logger = logging.getLogger(__name__)

@dataclass
class HealthStatus:
    """System health status information."""
    
    # Overall health
    status: str  # healthy, warning, critical, unknown
    score: float  # 0-100 health score
    timestamp: str
    
    # Component health
    system_resources: Dict[str, Any]
    api_connectivity: Dict[str, bool]
    environment_security: Dict[str, Any]
    file_system: Dict[str, Any]
    dependencies: Dict[str, bool]
    
    # Recommendations and warnings with default empty lists
    warnings: List[str] = None
    recommendations: List[str] = None
    critical_issues: List[str] = None
    
    def __post_init__(self):
        """Initialize lists if not provided."""
        if self.warnings is None:
            self.warnings = []
        if self.recommendations is None:
            self.recommendations = []
        if self.critical_issues is None:
            self.critical_issues = []

class HealthChecker:
    """Comprehensive health checking for podcast production system."""
    
    def __init__(self, production_mode: bool = False):
        self.production_mode = production_mode
        self.last_check: Optional[HealthStatus] = None
        self.check_history: List[HealthStatus] = []
        
    def check_system_resources(self) -> Tuple[Dict[str, Any], List[str], List[str]]:
        """Check system resource health (memory, CPU, disk)."""
        resources = {}
        warnings = []
        critical = []
        
        try:
            # Memory check
            memory = psutil.virtual_memory()
            resources['memory'] = {
                'total_gb': memory.total / (1024**3),
                'available_gb': memory.available / (1024**3),
                'used_percent': memory.percent,
                'free_gb': memory.free / (1024**3)
            }
            
            # Memory thresholds
            if memory.percent > 90:
                critical.append(f"Critical memory usage: {memory.percent:.1f}% (>90%)")
            elif memory.percent > 75:
                warnings.append(f"High memory usage: {memory.percent:.1f}% (>75%)")
            
            # CPU check
            cpu_percent = psutil.cpu_percent(interval=1)
            resources['cpu'] = {
                'usage_percent': cpu_percent,
                'core_count': psutil.cpu_count(),
                'load_average': os.getloadavg() if hasattr(os, 'getloadavg') else None
            }
            
            # CPU thresholds
            if cpu_percent > 95:
                critical.append(f"Critical CPU usage: {cpu_percent:.1f}% (>95%)")
            elif cpu_percent > 80:
                warnings.append(f"High CPU usage: {cpu_percent:.1f}% (>80%)")
            
            # Disk space check
            disk = psutil.disk_usage('.')
            resources['disk'] = {
                'total_gb': disk.total / (1024**3),
                'free_gb': disk.free / (1024**3),
                'used_percent': (disk.used / disk.total) * 100,
                'free_percent': (disk.free / disk.total) * 100
            }
            
            # Disk thresholds
            used_percent = (disk.used / disk.total) * 100
            if used_percent > 95:
                critical.append(f"Critical disk usage: {used_percent:.1f}% (>95%)")
            elif used_percent > 85:
                warnings.append(f"High disk usage: {used_percent:.1f}% (>85%)")
            
            # Process information
            process = psutil.Process()
            resources['process'] = {
                'pid': process.pid,
                'memory_mb': process.memory_info().rss / (1024**2),
                'cpu_percent': process.cpu_percent(),
                'num_threads': process.num_threads(),
                'create_time': datetime.fromtimestamp(process.create_time()).isoformat()
            }
            
        except Exception as e:
            critical.append(f"Failed to collect system resources: {e}")
            logger.error(f"System resource check failed: {e}")
        
        return resources, warnings, critical
    
    def check_api_connectivity(self) -> Tuple[Dict[str, bool], List[str], List[str]]:
        """Check API key validity and basic connectivity."""
        connectivity = {}
        warnings = []
        critical = []
        
        try:
            # Use our security module for API validation
            api_results = validate_api_keys()
            connectivity = api_results.copy()
            
            # Count valid APIs
            valid_count = sum(1 for valid in api_results.values() if valid)
            total_count = len(api_results)
            
            if valid_count == 0:
                critical.append("No valid API keys found - system cannot function")
            elif valid_count < total_count * 0.5:  # Less than 50% valid
                warnings.append(f"Only {valid_count}/{total_count} API keys valid")
            
            # Check for essential APIs
            essential_apis = ['OPENAI_API_KEY', 'ELEVENLABS_API_KEY']
            for api in essential_apis:
                if api in api_results and not api_results[api]:
                    critical.append(f"Essential API {api} is invalid")
                    
        except Exception as e:
            critical.append(f"API connectivity check failed: {e}")
            logger.error(f"API connectivity check failed: {e}")
        
        return connectivity, warnings, critical
    
    def check_environment_security(self) -> Tuple[Dict[str, Any], List[str], List[str]]:
        """Check environment security and configuration."""
        security = {}
        warnings = []
        critical = []
        
        try:
            # Use our security module
            security_results = validate_environment_security()
            security = security_results.copy()
            
            # Check security score
            score = security_results.get('score', 0)
            if score < 50:
                critical.append(f"Critical security score: {score}/100 (<50)")
            elif score < 70:
                warnings.append(f"Low security score: {score}/100 (<70)")
            
            # Check for security warnings
            if 'warnings' in security_results:
                for warning in security_results['warnings']:
                    warnings.append(f"Security: {warning}")
            
        except Exception as e:
            critical.append(f"Environment security check failed: {e}")
            logger.error(f"Environment security check failed: {e}")
        
        return security, warnings, critical
    
    def check_file_system(self) -> Tuple[Dict[str, Any], List[str], List[str]]:
        """Check file system health and required directories."""
        filesystem = {}
        warnings = []
        critical = []
        
        try:
            # Check required directories
            required_dirs = [
                'core',
                'logs', 
                'output',
                'episodes'
            ]
            
            filesystem['directories'] = {}
            for dir_name in required_dirs:
                exists = os.path.exists(dir_name)
                readable = False
                writable = False
                
                if exists:
                    readable = os.access(dir_name, os.R_OK)
                    writable = os.access(dir_name, os.W_OK)
                
                filesystem['directories'][dir_name] = {
                    'exists': exists,
                    'readable': readable,
                    'writable': writable
                }
                
                if not exists:
                    warnings.append(f"Directory {dir_name} does not exist")
                elif not readable:
                    critical.append(f"Directory {dir_name} is not readable")
                elif not writable:
                    critical.append(f"Directory {dir_name} is not writable")
            
            # Check file permissions on key files
            key_files = [
                'main.py',
                'core/security.py',
                'core/state.py',
                'core/monitoring.py'
            ]
            
            filesystem['files'] = {}
            for file_name in key_files:
                exists = os.path.exists(file_name)
                readable = os.access(file_name, os.R_OK) if exists else False
                
                filesystem['files'][file_name] = {
                    'exists': exists,
                    'readable': readable,
                    'size_bytes': os.path.getsize(file_name) if exists else 0
                }
                
                if not exists:
                    critical.append(f"Key file {file_name} is missing")
                elif not readable:
                    critical.append(f"Key file {file_name} is not readable")
            
            # Check log directory and rotation
            logs_dir = Path('logs')
            if logs_dir.exists():
                log_files = list(logs_dir.glob('*.log'))
                total_log_size = sum(f.stat().st_size for f in log_files)
                
                filesystem['logs'] = {
                    'log_count': len(log_files),
                    'total_size_mb': total_log_size / (1024**2),
                    'oldest_log': min((f.stat().st_mtime for f in log_files), default=None)
                }
                
                # Check for large log files
                if total_log_size > 100 * 1024**2:  # >100MB
                    warnings.append(f"Large log files: {total_log_size/(1024**2):.1f}MB")
                    
        except Exception as e:
            critical.append(f"File system check failed: {e}")
            logger.error(f"File system check failed: {e}")
        
        return filesystem, warnings, critical
    
    def check_dependencies(self) -> Tuple[Dict[str, bool], List[str], List[str]]:
        """Check Python dependencies and imports."""
        dependencies = {}
        warnings = []
        critical = []
        
        # Required packages for podcast production
        required_packages = {
            'psutil': 'System resource monitoring',
            'requests': 'HTTP requests for API calls', 
            'datetime': 'Built-in datetime functionality',
            'json': 'Built-in JSON processing',
            'os': 'Built-in OS interface',
            'sys': 'Built-in system interface',
            'time': 'Built-in time functionality',
            'logging': 'Built-in logging'
        }
        
        for package, description in required_packages.items():
            try:
                __import__(package)
                dependencies[package] = True
            except ImportError as e:
                dependencies[package] = False
                if package in ['psutil', 'requests']:  # Critical packages
                    critical.append(f"Missing critical package: {package} ({description})")
                else:
                    warnings.append(f"Missing package: {package} ({description})")
        
        # Check Python version
        python_version = sys.version_info
        dependencies['python_version'] = f"{python_version.major}.{python_version.minor}.{python_version.micro}"
        
        if python_version.major < 3 or (python_version.major == 3 and python_version.minor < 8):
            critical.append(f"Unsupported Python version: {dependencies['python_version']} (requires 3.8+)")
        elif python_version.minor < 9:
            warnings.append(f"Old Python version: {dependencies['python_version']} (3.9+ recommended)")
        
        return dependencies, warnings, critical
    
    def calculate_health_score(self, warnings: List[str], critical: List[str]) -> float:
        """Calculate overall health score (0-100)."""
        base_score = 100.0
        
        # Deduct points for issues
        for warning in warnings:
            if 'memory' in warning.lower() or 'cpu' in warning.lower():
                base_score -= 10  # Resource issues are serious
            elif 'api' in warning.lower():
                base_score -= 15  # API issues are very serious
            elif 'security' in warning.lower():
                base_score -= 12  # Security issues are serious
            else:
                base_score -= 5   # General warnings
        
        for critical_issue in critical:
            if 'memory' in critical_issue.lower() or 'cpu' in critical_issue.lower():
                base_score -= 25  # Critical resource issues
            elif 'api' in critical_issue.lower():
                base_score -= 30  # Critical API issues
            elif 'security' in critical_issue.lower():
                base_score -= 35  # Critical security issues
            else:
                base_score -= 20  # General critical issues
        
        return max(0.0, base_score)
    
    def determine_status(self, score: float, critical: List[str]) -> str:
        """Determine overall health status."""
        if critical:
            return "critical"
        elif score >= 85:
            return "healthy"
        elif score >= 60:
            return "warning"
        else:
            return "critical"
    
    def generate_recommendations(self, warnings: List[str], critical: List[str], 
                               resources: Dict[str, Any]) -> List[str]:
        """Generate actionable recommendations."""
        recommendations = []
        
        # Resource recommendations
        if 'system_resources' in resources:
            memory = resources['system_resources'].get('memory', {})
            if memory.get('used_percent', 0) > 75:
                recommendations.append("Consider closing unnecessary applications to free memory")
                recommendations.append("Increase available RAM if running production workloads")
            
            cpu = resources['system_resources'].get('cpu', {})
            if cpu.get('usage_percent', 0) > 80:
                recommendations.append("Reduce CPU-intensive processes during podcast production")
                recommendations.append("Consider upgrading to higher-core-count CPU")
            
            disk = resources['system_resources'].get('disk', {})
            if disk.get('used_percent', 0) > 85:
                recommendations.append("Clean up old log files and temporary data")
                recommendations.append("Consider adding additional storage capacity")
        
        # API recommendations
        api_issues = [w for w in warnings + critical if 'api' in w.lower()]
        if api_issues:
            recommendations.append("Verify API keys are correctly configured in .env file")
            recommendations.append("Check API key permissions and quotas with providers")
            recommendations.append("Test API connectivity independently")
        
        # Security recommendations
        security_issues = [w for w in warnings + critical if 'security' in w.lower()]
        if security_issues:
            recommendations.append("Review environment security configuration")
            recommendations.append("Ensure production environment variables are properly set")
            recommendations.append("Validate API key formats and permissions")
        
        # File system recommendations
        filesystem_issues = [w for w in warnings + critical if any(term in w.lower() for term in ['directory', 'file', 'permission'])]
        if filesystem_issues:
            recommendations.append("Create missing directories with proper permissions")
            recommendations.append("Fix file permission issues for key system files")
            recommendations.append("Implement log rotation to prevent disk space issues")
        
        return recommendations
    
    def perform_full_health_check(self) -> HealthStatus:
        """Perform comprehensive health check."""
        logger.info("🏥 Starting comprehensive health check...")
        start_time = time.time()
        
        all_warnings = []
        all_critical = []
        
        # Check system resources
        resources, resource_warnings, resource_critical = self.check_system_resources()
        all_warnings.extend(resource_warnings)
        all_critical.extend(resource_critical)
        
        # Check API connectivity
        apis, api_warnings, api_critical = self.check_api_connectivity()
        all_warnings.extend(api_warnings)
        all_critical.extend(api_critical)
        
        # Check environment security
        security, security_warnings, security_critical = self.check_environment_security()
        all_warnings.extend(security_warnings)
        all_critical.extend(security_critical)
        
        # Check file system
        filesystem, fs_warnings, fs_critical = self.check_file_system()
        all_warnings.extend(fs_warnings)
        all_critical.extend(fs_critical)
        
        # Check dependencies
        dependencies, dep_warnings, dep_critical = self.check_dependencies()
        all_warnings.extend(dep_warnings)
        all_critical.extend(dep_critical)
        
        # Calculate health score and status
        score = self.calculate_health_score(all_warnings, all_critical)
        status = self.determine_status(score, all_critical)
        
        # Generate recommendations
        all_results = {
            'system_resources': resources,
            'api_connectivity': apis,
            'environment_security': security,
            'file_system': filesystem,
            'dependencies': dependencies
        }
        recommendations = self.generate_recommendations(all_warnings, all_critical, all_results)
        
        # Create health status
        health_status = HealthStatus(
            status=status,
            score=score,
            timestamp=datetime.now().isoformat(),
            system_resources=resources,
            api_connectivity=apis,
            environment_security=security,
            file_system=filesystem,
            dependencies=dependencies,
            warnings=all_warnings,
            recommendations=recommendations,
            critical_issues=all_critical
        )
        
        # Store results
        self.last_check = health_status
        self.check_history.append(health_status)
        
        # Keep only last 10 checks
        if len(self.check_history) > 10:
            self.check_history = self.check_history[-10:]
        
        duration = time.time() - start_time
        logger.info(f"🏥 Health check completed in {duration:.2f}s - Status: {status.upper()} (Score: {score:.1f}/100)")
        
        return health_status
    
    def is_production_ready(self) -> bool:
        """Check if system is ready for production podcast generation."""
        if not self.last_check:
            self.perform_full_health_check()
        
        # Production readiness criteria
        criteria = {
            'no_critical_issues': len(self.last_check.critical_issues) == 0,
            'health_score_above_70': self.last_check.score >= 70,
            'essential_apis_valid': all(
                self.last_check.api_connectivity.get(api, False) 
                for api in ['OPENAI_API_KEY', 'ELEVENLABS_API_KEY']
            ),
            'adequate_resources': (
                self.last_check.system_resources.get('memory', {}).get('used_percent', 100) < 85 and
                self.last_check.system_resources.get('disk', {}).get('used_percent', 100) < 90
            )
        }
        
        return all(criteria.values())
    
    def get_health_summary(self) -> Dict[str, Any]:
        """Get a summary of the current health status."""
        if not self.last_check:
            return {"status": "unknown", "message": "No health check performed yet"}
        
        return {
            "status": self.last_check.status,
            "score": self.last_check.score,
            "timestamp": self.last_check.timestamp,
            "production_ready": self.is_production_ready(),
            "warnings_count": len(self.last_check.warnings),
            "critical_count": len(self.last_check.critical_issues),
            "recommendations_count": len(self.last_check.recommendations),
            "system_health": {
                "memory_usage": self.last_check.system_resources.get('memory', {}).get('used_percent'),
                "cpu_usage": self.last_check.system_resources.get('cpu', {}).get('usage_percent'),
                "disk_usage": self.last_check.system_resources.get('disk', {}).get('used_percent')
            },
            "api_status": self.last_check.api_connectivity,
            "security_score": self.last_check.environment_security.get('score')
        }

def create_health_checker(production_mode: bool = False) -> HealthChecker:
    """Create a health checker instance."""
    return HealthChecker(production_mode=production_mode)

# Example usage for documentation
def example_usage():
    """Example of how to use the health checking system."""
    checker = create_health_checker(production_mode=True)
    
    # Perform full health check
    health_status = checker.perform_full_health_check()
    
    # Check production readiness
    ready = checker.is_production_ready()
    
    # Get summary
    summary = checker.get_health_summary()
    
    return health_status, ready, summary

if __name__ == "__main__":
    # Quick health check test
    checker = create_health_checker()
    
    print("SYSTEM HEALTH CHECK")
    print("=" * 60)
    
    health = checker.perform_full_health_check()
    
    print(f"\n📊 Health Status: {health.status.upper()} (Score: {health.score:.1f}/100)")
    print(f"🏭 Production Ready: {'✅ Yes' if checker.is_production_ready() else '❌ No'}")
    
    if health.critical_issues:
        print(f"\n🚨 Critical Issues ({len(health.critical_issues)}):")
        for issue in health.critical_issues:
            print(f"  - {issue}")
    
    if health.warnings:
        print(f"\n⚠️ Warnings ({len(health.warnings)}):")
        for warning in health.warnings:
            print(f"  - {warning}")
    
    if health.recommendations:
        print(f"\n💡 Recommendations ({len(health.recommendations)}):")
        for i, rec in enumerate(health.recommendations[:5], 1):  # Show first 5
            print(f"  {i}. {rec}")
    
    print(f"\n🔧 System Resources:")
    if 'memory' in health.system_resources:
        mem = health.system_resources['memory']
        print(f"  Memory: {mem['used_percent']:.1f}% used ({mem['available_gb']:.1f}GB available)")
    
    if 'cpu' in health.system_resources:
        cpu = health.system_resources['cpu']
        print(f"  CPU: {cpu['usage_percent']:.1f}% usage ({cpu['core_count']} cores)")
    
    if 'disk' in health.system_resources:
        disk = health.system_resources['disk']
        print(f"  Disk: {disk['used_percent']:.1f}% used ({disk['free_gb']:.1f}GB free)")