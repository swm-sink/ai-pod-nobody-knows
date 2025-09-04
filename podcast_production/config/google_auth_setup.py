#!/usr/bin/env python3
"""
Google OAuth 2.0 Service Account Setup for AI Podcast Production

This module handles the transition from deprecated Google API keys to OAuth 2.0
service account authentication for production and automated systems.

Features:
- Service account credential management
- Automatic token refresh
- Production-ready authentication
- Secure credential storage
- Migration assistance from API keys

SECURITY NOTE: This replaces the deprecated GOOGLE_API_KEY environment variable
with secure OAuth 2.0 service account authentication.

Setup Instructions:
1. Create a service account in Google Cloud Console
2. Download the JSON credentials file
3. Set GOOGLE_SERVICE_ACCOUNT_JSON environment variable
4. Use GoogleAuthManager for all Google API calls

Migration Path:
DEPRECATED: GOOGLE_API_KEY=AIza...
CURRENT:    GOOGLE_SERVICE_ACCOUNT_JSON=path/to/credentials.json
"""

import os
import json
import logging
from typing import Optional, Dict, Any
from pathlib import Path
from dataclasses import dataclass
from google.oauth2 import service_account
from google.auth.transport.requests import Request
from google.auth.exceptions import RefreshError
import warnings

logger = logging.getLogger(__name__)

@dataclass
class AuthConfig:
    """Configuration for Google OAuth 2.0 authentication."""
    service_account_path: Optional[str] = None
    service_account_json: Optional[str] = None
    scopes: list = None
    
    def __post_init__(self):
        if self.scopes is None:
            # Default scopes for Gemini API and other Google services
            self.scopes = [
                'https://www.googleapis.com/auth/generative-language.retriever',
                'https://www.googleapis.com/auth/generative-language',
                'https://www.googleapis.com/auth/cloud-platform'
            ]

class GoogleAuthManager:
    """
    Production-ready Google OAuth 2.0 service account authentication manager.
    
    This class handles:
    - Service account credential loading
    - Token generation and refresh
    - Secure credential management
    - Migration from deprecated API keys
    """
    
    def __init__(self, config: Optional[AuthConfig] = None):
        """
        Initialize Google authentication manager.
        
        Args:
            config: AuthConfig object, if None will load from environment
        """
        self.config = config or self._load_config_from_env()
        self.credentials = None
        self._token = None
        
        # Check for deprecated API key usage
        self._check_deprecated_api_key()
        
        # Initialize credentials
        self._initialize_credentials()
    
    def _load_config_from_env(self) -> AuthConfig:
        """Load authentication configuration from environment variables."""
        # Priority: JSON path > inline JSON > error
        service_account_path = os.getenv('GOOGLE_SERVICE_ACCOUNT_JSON')
        service_account_inline = os.getenv('GOOGLE_SERVICE_ACCOUNT_CREDENTIALS')
        
        return AuthConfig(
            service_account_path=service_account_path,
            service_account_json=service_account_inline
        )
    
    def _check_deprecated_api_key(self):
        """Check for deprecated GOOGLE_API_KEY usage and provide migration guidance."""
        deprecated_key = os.getenv('GOOGLE_API_KEY')
        if deprecated_key:
            warnings.warn(
                "\n" + "="*80 + "\n"
                "🚫 GOOGLE API KEY DEPRECATION WARNING\n"
                "="*80 + "\n"
                "The GOOGLE_API_KEY environment variable is DEPRECATED.\n"
                "Google is phasing out API keys for production use.\n\n"
                "MIGRATION REQUIRED:\n"
                "1. Create a service account in Google Cloud Console\n"
                "2. Download the JSON credentials file\n"
                "3. Set GOOGLE_SERVICE_ACCOUNT_JSON=/path/to/credentials.json\n"
                "4. Remove GOOGLE_API_KEY from your .env file\n\n"
                "For automated systems and production, OAuth 2.0 with service accounts\n"
                "provides better security, auditability, and key rotation.\n"
                "="*80 + "\n",
                DeprecationWarning,
                stacklevel=2
            )
    
    def _initialize_credentials(self):
        """Initialize Google service account credentials."""
        try:
            if self.config.service_account_path and Path(self.config.service_account_path).exists():
                # Load from JSON file
                self.credentials = service_account.Credentials.from_service_account_file(
                    self.config.service_account_path,
                    scopes=self.config.scopes
                )
                logger.info(f"Loaded service account credentials from {self.config.service_account_path}")
                
            elif self.config.service_account_json:
                # Load from inline JSON string
                service_account_info = json.loads(self.config.service_account_json)
                self.credentials = service_account.Credentials.from_service_account_info(
                    service_account_info,
                    scopes=self.config.scopes
                )
                logger.info("Loaded service account credentials from inline JSON")
                
            else:
                logger.warning("No Google service account credentials configured")
                self.credentials = None
                
        except (json.JSONDecodeError, ValueError, FileNotFoundError) as e:
            logger.error(f"Failed to load Google service account credentials: {e}")
            self.credentials = None
        except Exception as e:
            logger.error(f"Unexpected error loading Google credentials: {e}")
            self.credentials = None
    
    def get_access_token(self) -> Optional[str]:
        """
        Get current access token, refreshing if necessary.
        
        Returns:
            Valid access token string or None if authentication failed
        """
        if not self.credentials:
            logger.warning("No Google credentials available for token generation")
            return None
        
        try:
            # Refresh token if needed
            if not self.credentials.valid:
                if self.credentials.expired and self.credentials.refresh_token:
                    self.credentials.refresh(Request())
                else:
                    logger.error("Google credentials are invalid and cannot be refreshed")
                    return None
            
            return self.credentials.token
            
        except RefreshError as e:
            logger.error(f"Failed to refresh Google access token: {e}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error getting access token: {e}")
            return None
    
    def get_auth_headers(self) -> Dict[str, str]:
        """
        Get authentication headers for API requests.
        
        Returns:
            Dictionary with Authorization header or empty dict if no token
        """
        token = self.get_access_token()
        if token:
            return {"Authorization": f"Bearer {token}"}
        return {}
    
    def is_authenticated(self) -> bool:
        """
        Check if authentication is properly configured and working.
        
        Returns:
            True if authentication is ready, False otherwise
        """
        return self.credentials is not None and self.get_access_token() is not None
    
    def get_service_account_info(self) -> Dict[str, Any]:
        """
        Get information about the configured service account (for debugging).
        
        Returns:
            Dictionary with service account information
        """
        if not self.credentials or not hasattr(self.credentials, '_service_account_email'):
            return {"status": "No service account configured"}
        
        return {
            "status": "Service account configured",
            "email": getattr(self.credentials, '_service_account_email', 'Unknown'),
            "project_id": getattr(self.credentials, '_project_id', 'Unknown'),
            "scopes": self.config.scopes,
            "valid": self.credentials.valid if self.credentials else False
        }

def create_setup_guide():
    """Generate a setup guide for Google OAuth 2.0 service account configuration."""
    guide = """
🔐 GOOGLE OAUTH 2.0 SERVICE ACCOUNT SETUP GUIDE
===============================================

IMPORTANT: Google API keys (AIza...) are being deprecated for production use.
This guide helps you migrate to secure OAuth 2.0 service account authentication.

STEP 1: Create a Service Account
-------------------------------
1. Go to Google Cloud Console: https://console.cloud.google.com/
2. Select your project (or create a new one)
3. Navigate to "IAM & Admin" > "Service Accounts"
4. Click "Create Service Account"
5. Fill in details:
   - Name: "AI Podcast Production"
   - Description: "Service account for automated podcast generation"
6. Click "Create and Continue"

STEP 2: Grant Required Permissions
---------------------------------
Add these roles to your service account:
- "Generative AI User" (for Gemini API access)
- "Service Usage Consumer" (for API usage)

STEP 3: Create and Download Credentials
--------------------------------------
1. Click on your newly created service account
2. Go to "Keys" tab
3. Click "Add Key" > "Create new key"
4. Choose "JSON" format
5. Download the JSON file (keep it secure!)

STEP 4: Configure Environment Variables
--------------------------------------
Add to your .env file:

# Option A: File path (recommended for development)
GOOGLE_SERVICE_ACCOUNT_JSON=/path/to/your/credentials.json

# Option B: Inline JSON (for containers/deployment)
GOOGLE_SERVICE_ACCOUNT_CREDENTIALS='{"type":"service_account","project_id":"your-project",...}'

STEP 5: Remove Deprecated API Key
---------------------------------
Remove this line from your .env file:
# GOOGLE_API_KEY=AIza...  # DEPRECATED - remove this

STEP 6: Test Configuration
-------------------------
Run the validation:
python -m config.google_auth_setup --test

SECURITY BEST PRACTICES:
-----------------------
✅ Never commit the credentials JSON file to git
✅ Use IAM roles with minimum required permissions  
✅ Regularly rotate service account keys
✅ Monitor service account usage in Cloud Console
✅ Use different service accounts for dev/staging/prod

TROUBLESHOOTING:
---------------
- Ensure the Generative Language API is enabled in your project
- Check that your service account has the correct IAM roles
- Verify the JSON credentials file is valid and accessible
- Make sure you're using the correct project ID

For more help, see: https://cloud.google.com/docs/authentication/provide-credentials-adc
"""
    return guide

def test_google_auth() -> bool:
    """
    Test Google OAuth 2.0 authentication configuration.
    
    Returns:
        True if authentication is working, False otherwise
    """
    print("🔐 Testing Google OAuth 2.0 Authentication...")
    
    auth_manager = GoogleAuthManager()
    
    # Check authentication status
    if not auth_manager.is_authenticated():
        print("❌ Google authentication failed")
        print("\nTroubleshooting:")
        print("1. Ensure GOOGLE_SERVICE_ACCOUNT_JSON is set in your .env file")
        print("2. Verify the credentials JSON file exists and is valid")
        print("3. Check that your service account has required permissions")
        print("4. Run: python -m config.google_auth_setup --setup-guide")
        return False
    
    # Get service account info
    info = auth_manager.get_service_account_info()
    print("✅ Google authentication successful!")
    print(f"   Service Account: {info.get('email', 'Unknown')}")
    print(f"   Project ID: {info.get('project_id', 'Unknown')}")
    print(f"   Scopes: {len(info.get('scopes', []))} configured")
    
    # Test token generation
    token = auth_manager.get_access_token()
    if token:
        print(f"✅ Access token generated successfully (length: {len(token)})")
    else:
        print("❌ Failed to generate access token")
        return False
    
    return True

def main():
    """Command-line interface for Google authentication setup."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Google OAuth 2.0 setup for AI Podcast Production")
    parser.add_argument("--setup-guide", action="store_true", help="Show setup guide")
    parser.add_argument("--test", action="store_true", help="Test authentication configuration")
    
    args = parser.parse_args()
    
    if args.setup_guide:
        print(create_setup_guide())
    elif args.test:
        success = test_google_auth()
        exit(0 if success else 1)
    else:
        print("Google OAuth 2.0 Service Account Setup")
        print("Usage:")
        print("  --setup-guide  Show complete setup instructions")
        print("  --test         Test current authentication configuration")

if __name__ == "__main__":
    main()