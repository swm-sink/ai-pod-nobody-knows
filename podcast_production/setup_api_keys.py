#!/usr/bin/env python3
"""
Interactive API Key Setup for AI Podcast Production System

This script helps users set up their API keys quickly and securely.
It provides guidance, validation, and creates a properly configured .env file.

Features:
- Interactive prompts for each API key
- Real-time format validation
- Security best practices guidance
- Google OAuth migration assistance
- Cost estimation and budget setup

Usage:
    python setup_api_keys.py
    python setup_api_keys.py --quick-start
    python setup_api_keys.py --validate-only

Version: 1.0.0
Date: September 2025
"""

import os
import sys
import argparse
from pathlib import Path
from typing import Dict, Optional, List, Tuple
import getpass
from config.api_key_validator import APIKeyValidator, APIProvider
from config.google_auth_setup import GoogleAuthManager

class APIKeySetup:
    """Interactive API key setup manager."""
    
    def __init__(self):
        """Initialize the setup manager."""
        self.env_file = Path(".env")
        self.env_example = Path(".env.example")
        self.validator = APIKeyValidator()
        self.collected_keys = {}
        self.estimated_cost = 0.0
    
    def print_welcome(self):
        """Print welcome message and overview."""
        print("🚀 AI Podcast Production System - API Key Setup")
        print("=" * 60)
        print()
        print("This interactive setup will help you configure API keys for:")
        print("• OpenAI (GPT models for research & scripts)")
        print("• Anthropic (Claude for quality validation)")
        print("• Perplexity (Real-time research & fact-checking)")
        print("• ElevenLabs (High-quality text-to-speech)")
        print("• Google OAuth 2.0 (Optional - service accounts)")
        print("• Langfuse (Optional - observability & tracking)")
        print()
        print("💰 Expected cost per episode: $4.50-8.00")
        print("🎯 Target cost: ≤$5.51 per episode")
        print()
    
    def check_existing_env(self) -> bool:
        """Check if .env file already exists and handle appropriately."""
        if self.env_file.exists():
            print("⚠️  Existing .env file found!")
            print()
            
            # Quick validation of existing file
            print("🔍 Validating existing configuration...")
            results = self.validator.validate_all()
            
            if results["all_valid"]:
                print("✅ Your existing configuration is valid!")
                print(f"   📊 Valid keys: {results['valid_keys']}/{results['total_keys']}")
                print(f"   🚀 Production ready: {results['ready_for_production']}")
                
                choice = input("\nWould you like to:\n(k)eep existing, (u)pdate specific keys, or (r)eplace all? [k/u/r]: ").lower()
                
                if choice == 'k':
                    print("✅ Keeping existing configuration.")
                    return True
                elif choice == 'u':
                    return self.update_specific_keys()
                elif choice == 'r':
                    print("🔄 Creating new configuration...")
                    return False
                else:
                    print("Invalid choice. Keeping existing configuration.")
                    return True
            else:
                print("❌ Issues found in existing configuration:")
                for issue in results["issues"][:3]:  # Show first 3 issues
                    print(f"   • {issue}")
                
                choice = input("\nWould you like to (f)ix issues or (r)eplace with new config? [f/r]: ").lower()
                return choice != 'r'
        
        return False
    
    def update_specific_keys(self) -> bool:
        """Allow user to update specific API keys."""
        print("\n🔧 Select keys to update:")
        
        # Load current values
        current_values = {}
        try:
            with open(self.env_file, 'r') as f:
                for line in f:
                    if '=' in line and not line.strip().startswith('#'):
                        key, value = line.strip().split('=', 1)
                        current_values[key] = value
        except Exception as e:
            print(f"Error reading .env file: {e}")
            return False
        
        # Show current status and allow selection
        keys_to_update = []
        for key_name in self.validator.validation_patterns.keys():
            current = current_values.get(key_name, "Not set")
            masked = self.validator._mask_key(current) if current != "Not set" else current
            
            config = self.validator.validation_patterns[key_name]
            required = "REQUIRED" if config["required"] else "optional"
            
            update = input(f"Update {key_name} ({required}) [{masked}]? [y/N]: ").lower() == 'y'
            if update:
                keys_to_update.append(key_name)
        
        if keys_to_update:
            print(f"\n📝 Updating {len(keys_to_update)} keys...")
            for key_name in keys_to_update:
                self.collect_single_key(key_name)
            
            self.save_env_file(update_mode=True)
            return True
        else:
            print("No keys selected for update.")
            return True
    
    def collect_api_keys(self):
        """Collect all required API keys interactively."""
        print("📝 Let's collect your API keys...")
        print("💡 You can skip optional keys by pressing Enter")
        print()
        
        # Process keys in logical order
        key_order = [
            "OPENAI_API_KEY",
            "ANTHROPIC_API_KEY", 
            "PERPLEXITY_API_KEY",
            "ELEVENLABS_API_KEY",
            "GOOGLE_API_KEY",
            "LANGFUSE_PUBLIC_KEY",
            "LANGFUSE_SECRET_KEY"
        ]
        
        for key_name in key_order:
            if key_name in self.validator.validation_patterns:
                self.collect_single_key(key_name)
                print()
    
    def collect_single_key(self, key_name: str):
        """Collect and validate a single API key."""
        config = self.validator.validation_patterns[key_name]
        provider = config["provider"].value
        required = config["required"]
        description = config["description"]
        
        # Handle special cases
        if key_name == "GOOGLE_API_KEY":
            self.handle_google_auth()
            return
        
        # Display context
        status = "REQUIRED" if required else "optional"
        print(f"🔑 {provider} API Key ({status})")
        print(f"   {description}")
        
        if "deprecation_warning" in config:
            print(f"   ⚠️  {config['deprecation_warning']}")
        
        # Get the key
        while True:
            if required:
                key_value = getpass.getpass(f"   Enter {key_name}: ").strip()
                if not key_value:
                    print("   ❌ This key is required. Please enter a value.")
                    continue
            else:
                key_value = getpass.getpass(f"   Enter {key_name} (or press Enter to skip): ").strip()
                if not key_value:
                    print("   ⏭️  Skipping optional key")
                    break
            
            # Validate format
            validation = self.validator._validate_key_format(key_name, key_value)
            if validation.format_valid:
                print(f"   ✅ Format validated for {provider}")
                self.collected_keys[key_name] = key_value
                self.update_cost_estimate(provider)
                break
            else:
                print(f"   ❌ Invalid format. Expected pattern for {provider} API keys.")
                print("   💡 Double-check you copied the key correctly from the provider.")
                retry = input("   Try again? [Y/n]: ").lower() != 'n'
                if not retry:
                    if not required:
                        print("   ⏭️  Skipping this key")
                    break
    
    def handle_google_auth(self):
        """Handle Google authentication configuration."""
        print("🔑 Google Authentication (optional)")
        print("   Used for additional Google services integration")
        print()
        print("🚫 IMPORTANT: Google API keys are being deprecated!")
        print("   Production systems should use OAuth 2.0 service accounts.")
        print()
        
        choice = input("Configure Google authentication? [y/N]: ").lower()
        if choice != 'y':
            print("   ⏭️  Skipping Google authentication")
            return
        
        print()
        print("Choose authentication method:")
        print("1. OAuth 2.0 Service Account (RECOMMENDED for production)")
        print("2. API Key (DEPRECATED - development/testing only)")
        print("3. Skip Google authentication")
        
        method = input("Select method [1/2/3]: ").strip()
        
        if method == '1':
            self.setup_google_oauth()
        elif method == '2':
            print("\n⚠️  Using deprecated API key method...")
            self.collect_single_key("GOOGLE_API_KEY")
        else:
            print("   ⏭️  Skipping Google authentication")
    
    def setup_google_oauth(self):
        """Guide user through Google OAuth 2.0 setup."""
        print("\n🔐 Google OAuth 2.0 Service Account Setup")
        print("   This is the secure, production-ready method.")
        print()
        
        has_service_account = input("Do you already have a Google Cloud service account? [y/N]: ").lower() == 'y'
        
        if not has_service_account:
            print("\n📚 First, create a service account:")
            print("1. Go to: https://console.cloud.google.com/")
            print("2. Select/create your project")
            print("3. Navigate to 'IAM & Admin' > 'Service Accounts'")
            print("4. Click 'Create Service Account'")
            print("5. Add roles: 'Generative AI User', 'Service Usage Consumer'")
            print("6. Create and download JSON key file")
            print()
            
            ready = input("Have you completed these steps? [y/N]: ").lower() == 'y'
            if not ready:
                print("   ⏭️  Skipping Google OAuth setup for now")
                print("   💡  Run 'python -m config.google_auth_setup --setup-guide' later")
                return
        
        # Get credentials file path
        creds_path = input("Enter path to your service account JSON file: ").strip()
        
        if creds_path and Path(creds_path).exists():
            self.collected_keys["GOOGLE_SERVICE_ACCOUNT_JSON"] = creds_path
            print("   ✅ Google OAuth 2.0 configured with service account")
        else:
            print("   ❌ File not found. Skipping Google OAuth setup.")
            print("   💡  You can configure this later in your .env file")
    
    def update_cost_estimate(self, provider: str):
        """Update estimated cost per episode based on provider."""
        cost_estimates = {
            "OpenAI": 2.50,
            "Anthropic": 1.50, 
            "Perplexity": 0.75,
            "ElevenLabs": 1.75,
            "Google": 0.00,  # Usually free tier sufficient
            "Langfuse": 0.00  # Free observability
        }
        
        self.estimated_cost += cost_estimates.get(provider, 0.0)
    
    def setup_budget_controls(self):
        """Configure budget controls and cost limits."""
        print("💰 Budget Controls Setup")
        print("   Set spending limits to control costs per episode")
        print()
        print(f"   📊 Estimated cost with your providers: ${self.estimated_cost:.2f}/episode")
        print("   🎯 System target cost: ≤$5.51/episode")
        print()
        
        # Max episode cost
        default_max = max(5.51, self.estimated_cost * 1.2)
        max_cost_input = input(f"Maximum cost per episode [$]{default_max:.2f}]: ").strip()
        
        try:
            max_cost = float(max_cost_input) if max_cost_input else default_max
        except ValueError:
            max_cost = default_max
            print(f"   Using default: ${max_cost:.2f}")
        
        self.collected_keys["MAX_EPISODE_COST"] = str(max_cost)
        self.collected_keys["COST_WARNING_THRESHOLD"] = str(max_cost * 0.8)
        self.collected_keys["COST_CRITICAL_THRESHOLD"] = str(max_cost * 0.9)
        
        # Quality threshold
        quality_input = input("Minimum quality score (0-10) [8.0]: ").strip()
        try:
            quality_threshold = float(quality_input) if quality_input else 8.0
        except ValueError:
            quality_threshold = 8.0
            print("   Using default: 8.0")
        
        self.collected_keys["QUALITY_THRESHOLD"] = str(quality_threshold)
        
        print(f"   ✅ Budget controls configured:")
        print(f"      Max cost: ${max_cost:.2f}/episode")
        print(f"      Quality threshold: {quality_threshold}/10")
    
    def save_env_file(self, update_mode: bool = False):
        """Save collected keys to .env file."""
        print("💾 Saving configuration...")
        
        if update_mode and self.env_file.exists():
            # Update existing file
            self.update_env_file()
        else:
            # Create new file from template
            self.create_env_file()
        
        print(f"   ✅ Configuration saved to {self.env_file}")
        print("   🔒 File permissions set to 600 (secure)")
        
        # Set secure permissions
        os.chmod(self.env_file, 0o600)
    
    def create_env_file(self):
        """Create new .env file from template."""
        # Start with template if available
        if self.env_example.exists():
            with open(self.env_example, 'r') as f:
                template_content = f.read()
        else:
            template_content = "# AI Podcast Production Environment Configuration\n\n"
        
        # Replace placeholders with actual values
        with open(self.env_file, 'w') as f:
            for line in template_content.split('\n'):
                if '=' in line and not line.strip().startswith('#'):
                    key = line.split('=')[0].strip()
                    if key in self.collected_keys:
                        f.write(f"{key}={self.collected_keys[key]}\n")
                    else:
                        f.write(line + '\n')
                else:
                    f.write(line + '\n')
            
            # Add any additional keys not in template
            f.write("\n# Additional Configuration\n")
            for key, value in self.collected_keys.items():
                if not any(key in line for line in template_content.split('\n')):
                    f.write(f"{key}={value}\n")
    
    def update_env_file(self):
        """Update existing .env file with new values."""
        # Read current content
        lines = []
        try:
            with open(self.env_file, 'r') as f:
                lines = f.readlines()
        except Exception:
            lines = []
        
        # Update lines with new values
        updated_keys = set()
        with open(self.env_file, 'w') as f:
            for line in lines:
                if '=' in line and not line.strip().startswith('#'):
                    key = line.split('=')[0].strip()
                    if key in self.collected_keys:
                        f.write(f"{key}={self.collected_keys[key]}\n")
                        updated_keys.add(key)
                    else:
                        f.write(line)
                else:
                    f.write(line)
            
            # Add any new keys
            for key, value in self.collected_keys.items():
                if key not in updated_keys:
                    f.write(f"{key}={value}\n")
    
    def run_final_validation(self):
        """Run final validation on the configured system."""
        print("\n🔍 Final Validation")
        print("   Testing your API key configuration...")
        print()
        
        # Reload environment
        from dotenv import load_dotenv
        load_dotenv(override=True)
        
        # Run validation
        results = self.validator.validate_all()
        
        if results["all_valid"]:
            print("🎉 SUCCESS! All required API keys are valid.")
            print(f"   📊 Valid keys: {results['valid_keys']}/{results['total_keys']}")
            print(f"   💰 Estimated cost: ${self.estimated_cost:.2f}/episode")
            
            if results["ready_for_production"]:
                print("   🚀 Configuration is production-ready!")
            else:
                print("   ⚠️  Some deprecated keys detected - consider upgrading")
            
            print("\n🏁 Next Steps:")
            print("   1. Test system: python check_health.py")
            print("   2. Run first episode: python main.py --topic 'Test Episode' --dry-run")
            print("   3. Check costs: cat output/*_cost_report.json")
            
        else:
            print("❌ Configuration issues found:")
            for issue in results["issues"]:
                print(f"   • {issue}")
            
            print("\n💡 To fix:")
            print("   1. Review the issues above")
            print("   2. Edit your .env file")
            print("   3. Run: python -m config.api_key_validator")
        
        return results["all_valid"]
    
    def run_setup(self, quick_start: bool = False):
        """Run the complete setup process."""
        self.print_welcome()
        
        # Check existing configuration
        if not quick_start and self.check_existing_env():
            print("✅ Setup complete!")
            return True
        
        # Collect API keys
        self.collect_api_keys()
        
        if not self.collected_keys:
            print("❌ No API keys collected. Setup cancelled.")
            return False
        
        # Setup budget controls
        if not quick_start:
            self.setup_budget_controls()
        else:
            # Quick defaults
            self.collected_keys.update({
                "MAX_EPISODE_COST": "5.51",
                "COST_WARNING_THRESHOLD": "4.41",
                "COST_CRITICAL_THRESHOLD": "4.96",
                "QUALITY_THRESHOLD": "8.0"
            })
        
        # Save configuration
        self.save_env_file()
        
        # Final validation
        return self.run_final_validation()

def main():
    """Main entry point for API key setup."""
    parser = argparse.ArgumentParser(description="Interactive API Key Setup for AI Podcast Production")
    parser.add_argument("--quick-start", action="store_true", 
                       help="Skip optional configurations and use defaults")
    parser.add_argument("--validate-only", action="store_true",
                       help="Only validate existing configuration")
    
    args = parser.parse_args()
    
    if args.validate_only:
        print("🔍 Validating existing configuration...")
        validator = APIKeyValidator()
        results = validator.validate_all()
        validator.print_validation_report(results)
        sys.exit(0 if results["all_valid"] else 1)
    
    setup = APIKeySetup()
    success = setup.run_setup(quick_start=args.quick_start)
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()