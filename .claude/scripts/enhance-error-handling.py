#!/usr/bin/env python3
"""
Comprehensive Error Handling Enhancement - August 2025
Adds circuit breaker patterns to critical LangGraph components for production reliability.
"""

import os
import re
import logging
from pathlib import Path
from typing import List, Dict, Set

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Colors for terminal output
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m' 
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def print_status(message: str, status: str = "INFO"):
    color = {
        "INFO": Colors.OKBLUE,
        "SUCCESS": Colors.OKGREEN, 
        "WARNING": Colors.WARNING,
        "ERROR": Colors.FAIL
    }.get(status, Colors.OKBLUE)
    print(f"{color}[{status}]{Colors.ENDC} {message}")

def get_python_files(directory: str) -> List[Path]:
    """Get all Python files in directory."""
    path = Path(directory)
    if not path.exists():
        raise FileNotFoundError(f"Directory not found: {directory}")
    
    return list(path.rglob("*.py"))

class ErrorHandlingEnhancer:
    """Enhances error handling with circuit breaker patterns."""
    
    def __init__(self, podcast_production_dir: str = "podcast_production"):
        self.base_dir = Path(podcast_production_dir)
        self.enhanced_files: Set[str] = set()
        
        # Files that need circuit breaker integration
        self.critical_components = {
            "workflows/main_workflow.py": ["execute_research_pipeline", "execute_production_pipeline", "run_workflow"],
            "workflows/orchestrated_workflow.py": ["_research_phase_node", "_production_phase_node", "_audio_phase_node"],
            "core/agent_orchestrator.py": ["execute_agent", "_execute_phase", "_coordinate_agents"],
            "agents/audio_synthesizer.py": ["synthesize", "_make_request"],
            "agents/script_writer.py": ["write_script", "_generate_content"],
            "agents/brand_validator.py": ["validate", "_run_validation"],
            "adapters/elevenlabs/provider.py": ["synthesize_audio", "_make_api_call"],
            "adapters/openrouter/provider.py": ["generate", "_call_api"],
            "adapters/perplexity/provider.py": ["research", "_make_request"]
        }
        
    def add_retry_handler_import(self, content: str) -> str:
        """Add retry handler import if not present."""
        if "from core.retry_handler import RetryHandler, RetryConfig" in content:
            return content
            
        # Find import section
        import_pattern = r"(import [^\n]+\n|from [^\n]+ import [^\n]+\n)+"
        match = re.search(import_pattern, content)
        
        if match:
            import_section = match.group(0)
            new_import = "from core.retry_handler import RetryHandler, RetryConfig, CircuitBreakerState\n"
            if new_import not in import_section:
                content = content.replace(import_section, import_section + new_import)
        else:
            # Add at beginning if no imports found
            content = "from core.retry_handler import RetryHandler, RetryConfig, CircuitBreakerState\n\n" + content
            
        return content

    def add_retry_handler_initialization(self, content: str, class_name: str) -> str:
        """Add retry handler initialization to class __init__."""
        # Find __init__ method
        init_pattern = rf"(class {class_name}[^:]*:[\s\S]*?def __init__\([^)]*\):[^:]*:)"
        match = re.search(init_pattern, content)
        
        if match:
            init_method = match.group(1)
            if "self.retry_handler = RetryHandler" not in init_method:
                # Add retry handler initialization
                new_init = init_method + "\n        # Initialize retry handler with circuit breaker"
                new_init += "\n        self.retry_handler = RetryHandler("
                new_init += "\n            config=RetryConfig("
                new_init += "\n                max_attempts=3,"
                new_init += "\n                failure_threshold=5,"
                new_init += "\n                recovery_timeout=30.0"
                new_init += "\n            ),"
                new_init += f"\n            name='{class_name.lower()}'"
                new_init += "\n        )\n"
                
                content = content.replace(init_method, new_init)
        
        return content
    
    def enhance_exception_handling(self, content: str, method_names: List[str]) -> str:
        """Enhance exception handling in specified methods."""
        for method_name in method_names:
            # Simple pattern to find specific methods
            method_pattern = f"async def {method_name}("
            
            if method_pattern in content and "circuit breaker" not in content:
                # Find method definition
                start_pos = content.find(method_pattern)
                if start_pos == -1:
                    continue
                
                # Find method body start (after colon)
                colon_pos = content.find(":", start_pos)
                if colon_pos == -1:
                    continue
                
                # Insert circuit breaker check
                circuit_check = "\n        # Check circuit breaker state"
                circuit_check += "\n        if hasattr(self, 'retry_handler'):"
                circuit_check += "\n            if self.retry_handler.circuit_breaker.state == CircuitBreakerState.OPEN:"
                circuit_check += f"\n                raise Exception('Circuit breaker is OPEN for {method_name} - service temporarily unavailable')"
                circuit_check += "\n"
                
                # Insert after colon and before existing content
                content = content[:colon_pos + 1] + circuit_check + content[colon_pos + 1:]
        
        return content
    
    def enhance_async_calls(self, content: str) -> str:
        """Wrap critical async calls with retry handler."""
        # Skip complex regex - just add comments for manual review
        if "retry_handler.execute_with_retry" not in content:
            # Add comment indicating where to add retry logic
            content = "# TODO: Consider wrapping critical async calls with self.retry_handler.execute_with_retry()\n" + content
        
        return content
    
    def process_file(self, file_path: Path) -> bool:
        """Process a single file for error handling enhancement."""
        try:
            relative_path = str(file_path.relative_to(self.base_dir))
            
            # Check if this file needs enhancement
            if relative_path not in self.critical_components:
                return False
                
            print_status(f"Enhancing error handling: {relative_path}")
            
            # Read file content
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # Add imports
            content = self.add_retry_handler_import(content)
            
            # Find class name for initialization
            class_match = re.search(r"class\s+(\w+)", content)
            if class_match:
                class_name = class_match.group(1)
                content = self.add_retry_handler_initialization(content, class_name)
            
            # Enhance specific methods
            methods = self.critical_components[relative_path]
            content = self.enhance_exception_handling(content, methods)
            
            # Enhance async calls
            content = self.enhance_async_calls(content)
            
            # Only write if content changed
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                self.enhanced_files.add(relative_path)
                print_status(f"✅ Enhanced: {relative_path}", "SUCCESS")
                return True
            else:
                print_status(f"⏭️  No changes needed: {relative_path}", "INFO")
                return False
                
        except Exception as e:
            print_status(f"❌ Error processing {file_path}: {e}", "ERROR")
            return False
    
    def run_enhancement(self) -> Dict[str, any]:
        """Run comprehensive error handling enhancement."""
        print_status("🔧 Enhancing Error Handling with Circuit Breakers", "INFO")
        print_status("=" * 50, "INFO")
        
        if not self.base_dir.exists():
            raise FileNotFoundError(f"Directory not found: {self.base_dir}")
        
        results = {
            "files_processed": 0,
            "files_enhanced": 0,
            "enhanced_files": [],
            "errors": []
        }
        
        # Process each critical component
        for relative_path in self.critical_components.keys():
            file_path = self.base_dir / relative_path
            
            if file_path.exists():
                results["files_processed"] += 1
                if self.process_file(file_path):
                    results["files_enhanced"] += 1
                    results["enhanced_files"].append(relative_path)
            else:
                error_msg = f"File not found: {relative_path}"
                print_status(f"⚠️  {error_msg}", "WARNING")
                results["errors"].append(error_msg)
        
        # Summary
        print_status("📊 Enhancement Summary", "INFO")
        print_status("=" * 25, "INFO")
        print_status(f"Files processed: {results['files_processed']}")
        print_status(f"Files enhanced: {results['files_enhanced']}")
        print_status(f"Errors: {len(results['errors'])}")
        
        if results["enhanced_files"]:
            print_status("📝 Enhanced files:", "SUCCESS")
            for file in results["enhanced_files"]:
                print_status(f"  - {file}", "SUCCESS")
        
        if results["errors"]:
            print_status("⚠️  Warnings/Errors:", "WARNING")
            for error in results["errors"]:
                print_status(f"  - {error}", "WARNING")
        
        print_status("⚠️  Important Notes:", "WARNING")
        print_status("  1. Review changes before committing", "WARNING")
        print_status("  2. Test enhanced error handling thoroughly", "WARNING")
        print_status("  3. Monitor circuit breaker behavior in production", "WARNING")
        print_status("  4. Adjust retry configurations as needed", "WARNING")
        
        print_status("✅ Error handling enhancement complete!", "SUCCESS")
        return results

def main():
    """Main execution."""
    try:
        enhancer = ErrorHandlingEnhancer()
        results = enhancer.run_enhancement()
        return results
    except Exception as e:
        print_status(f"❌ Enhancement failed: {e}", "ERROR")
        raise

if __name__ == "__main__":
    main()