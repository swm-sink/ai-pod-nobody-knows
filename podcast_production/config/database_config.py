"""
Database Configuration for Production - August 2025
PostgreSQL setup for LangGraph checkpointer and persistent storage.
"""

import os
import logging
from typing import Optional, Dict, Any
from pathlib import Path

logger = logging.getLogger(__name__)


class DatabaseConfig:
    """
    Database configuration manager for production PostgreSQL setup.
    
    Handles connection strings, SSL settings, and production requirements
    for LangGraph PostgresSaver checkpointer.
    """
    
    def __init__(self):
        """Initialize database configuration."""
        self.config = self._load_config()
    
    def _load_config(self) -> Dict[str, Any]:
        """Load database configuration from environment and defaults."""
        config = {
            # Primary connection string sources (in priority order)
            "postgres_url": (
                os.getenv("POSTGRES_URL") or 
                os.getenv("DATABASE_URL") or 
                os.getenv("POSTGRESQL_URL")
            ),
            
            # Individual connection parameters (fallback)
            "host": os.getenv("POSTGRES_HOST", "localhost"),
            "port": int(os.getenv("POSTGRES_PORT", "5432")),
            "database": os.getenv("POSTGRES_DB", "podcast_production"),
            "username": os.getenv("POSTGRES_USER", "podcast"),
            "password": os.getenv("POSTGRES_PASSWORD"),
            
            # SSL and security settings
            "ssl_mode": os.getenv("POSTGRES_SSL_MODE", "prefer"),
            "ssl_require": os.getenv("POSTGRES_SSL_REQUIRE", "false").lower() == "true",
            
            # Connection pool settings
            "min_connections": int(os.getenv("POSTGRES_MIN_CONN", "1")),
            "max_connections": int(os.getenv("POSTGRES_MAX_CONN", "10")),
            "connection_timeout": int(os.getenv("POSTGRES_TIMEOUT", "30")),
            
            # LangGraph specific settings
            "schema": os.getenv("POSTGRES_SCHEMA", "public"),
            "table_prefix": os.getenv("LANGGRAPH_TABLE_PREFIX", "checkpoints"),
            
            # Development/production mode detection
            "environment": os.getenv("ENVIRONMENT", "development"),
            "is_production": os.getenv("ENVIRONMENT", "development").lower() == "production"
        }
        
        # Validate configuration
        self._validate_config(config)
        
        return config
    
    def _validate_config(self, config: Dict[str, Any]):
        """Validate database configuration."""
        if config["is_production"]:
            # Production requirements
            if not config["postgres_url"] and not config["password"]:
                logger.error("❌ Production requires either POSTGRES_URL or POSTGRES_PASSWORD")
                raise ValueError("Database credentials required for production")
            
            if not config["ssl_require"] and "localhost" not in str(config["host"]):
                logger.warning("⚠️ SSL not required for production database - security risk")
        
        # Validate port range
        if not (1 <= config["port"] <= 65535):
            raise ValueError(f"Invalid port number: {config['port']}")
        
        # Validate connection pool
        if config["max_connections"] < config["min_connections"]:
            raise ValueError("max_connections must be >= min_connections")
    
    def get_connection_string(self, for_langgraph: bool = True) -> str:
        """
        Get PostgreSQL connection string for production use.
        
        Args:
            for_langgraph: If True, ensures compatibility with LangGraph PostgresSaver
            
        Returns:
            PostgreSQL connection string
        """
        if self.config["postgres_url"]:
            # Use provided connection string
            connection_string = self.config["postgres_url"]
            logger.info(f"✅ Using provided PostgreSQL URL")
            
        else:
            # Build connection string from components
            password_part = f":{self.config['password']}" if self.config["password"] else ""
            ssl_part = f"?sslmode={self.config['ssl_mode']}" if self.config["ssl_mode"] != "disable" else ""
            
            connection_string = (
                f"postgresql://{self.config['username']}{password_part}@"
                f"{self.config['host']}:{self.config['port']}/{self.config['database']}"
                f"{ssl_part}"
            )
            
            logger.info(f"✅ Built PostgreSQL connection string from components")
        
        # Add LangGraph-specific parameters if needed
        if for_langgraph:
            separator = "&" if "?" in connection_string else "?"
            connection_string += f"{separator}application_name=podcast_production_langgraph"
        
        # Log connection details (without password)
        safe_string = connection_string.replace(self.config.get("password", ""), "***") if self.config.get("password") else connection_string
        logger.debug(f"Connection string: {safe_string}")
        
        return connection_string
    
    def get_config(self) -> Dict[str, Any]:
        """Get complete database configuration."""
        return self.config.copy()
    
    def is_available(self) -> bool:
        """
        Check if database configuration is available for production use.
        
        Returns:
            True if database can be configured for production
        """
        return bool(
            self.config["postgres_url"] or 
            (self.config["host"] and self.config["database"])
        )
    
    def requires_ssl(self) -> bool:
        """Check if SSL is required for this configuration."""
        return self.config["ssl_require"] or self.config["is_production"]
    
    def test_connection(self) -> bool:
        """
        Test database connection (supports PostgreSQL and SQLite).
        
        Returns:
            True if connection successful
        """
        try:
            connection_string = self.get_connection_string(for_langgraph=False)
            
            # Check if it's a SQLite connection
            if connection_string.startswith("sqlite://"):
                import sqlite3
                db_path = connection_string.replace("sqlite://", "")
                
                with sqlite3.connect(db_path) as conn:
                    cursor = conn.cursor()
                    cursor.execute("SELECT sqlite_version()")
                    version = cursor.fetchone()[0]
                    logger.info(f"✅ SQLite connection successful: {version}")
                    return True
            
            else:
                # PostgreSQL connection
                import psycopg2
                
                with psycopg2.connect(connection_string) as conn:
                    with conn.cursor() as cursor:
                        cursor.execute("SELECT version()")
                        version = cursor.fetchone()[0]
                        logger.info(f"✅ PostgreSQL connection successful: {version}")
                        return True
                    
        except ImportError as e:
            logger.warning(f"⚠️ Database driver not available: {e}")
            return False
        except Exception as e:
            logger.error(f"❌ Database connection failed: {e}")
            return False
    
    def create_env_template(self) -> str:
        """
        Create environment variable template for database configuration.
        
        Returns:
            Template string with all database environment variables
        """
        template = """
# PostgreSQL Configuration for AI Podcast Production System
# Choose ONE of the following approaches:

# Option 1: Full connection string (recommended for production)
POSTGRES_URL=postgresql://username:password@host:port/database?sslmode=require

# Option 2: Individual parameters (for development)
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=podcast_production
POSTGRES_USER=podcast
POSTGRES_PASSWORD=your_secure_password

# SSL Configuration (production recommended)
POSTGRES_SSL_MODE=require  # options: disable, allow, prefer, require, verify-ca, verify-full
POSTGRES_SSL_REQUIRE=true

# Connection Pool Settings
POSTGRES_MIN_CONN=1
POSTGRES_MAX_CONN=10
POSTGRES_TIMEOUT=30

# LangGraph Specific
POSTGRES_SCHEMA=public
LANGGRAPH_TABLE_PREFIX=checkpoints

# Environment Detection
ENVIRONMENT=production  # options: development, production
"""
        return template.strip()


# Global instance
_database_config = None


def get_database_config() -> DatabaseConfig:
    """Get global database configuration instance."""
    global _database_config
    if _database_config is None:
        _database_config = DatabaseConfig()
    return _database_config


def get_postgres_connection_string() -> Optional[str]:
    """
    Get PostgreSQL connection string for LangGraph production use.
    
    Returns:
        Connection string if available, None otherwise
    """
    config = get_database_config()
    if config.is_available():
        return config.get_connection_string(for_langgraph=True)
    return None


def is_postgres_configured() -> bool:
    """Check if PostgreSQL is properly configured for production."""
    config = get_database_config()
    return config.is_available()


def create_database_env_file():
    """Create .env.database template file."""
    config = get_database_config()
    template = config.create_env_template()
    
    env_file = Path(".env.database.example")
    with open(env_file, 'w') as f:
        f.write(template)
    
    logger.info(f"✅ Created database environment template: {env_file}")
    print(f"📁 Database configuration template created: {env_file}")
    print("📝 Copy to .env.database and configure your PostgreSQL settings")


if __name__ == "__main__":
    # Create environment template when run directly
    create_database_env_file()
    
    # Test current configuration
    config = get_database_config()
    print(f"\n🔍 Database Configuration Status:")
    print(f"   Available: {'✅ Yes' if config.is_available() else '❌ No'}")
    print(f"   Production: {'✅ Yes' if config.config['is_production'] else '🔧 Development'}")
    print(f"   SSL Required: {'✅ Yes' if config.requires_ssl() else '⚠️ No'}")
    
    if config.is_available():
        print(f"   Connection Test: {'✅ Success' if config.test_connection() else '❌ Failed'}")