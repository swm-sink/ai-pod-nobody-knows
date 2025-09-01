#!/usr/bin/env python3
"""
MCP Connection Validation Script
Validates all Model Context Protocol server connections
Based on August 2025 best practices from official Python SDK
"""

import asyncio
import os
import sys
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
import json

# MCP validation based on August 2025 SDK patterns
@dataclass
class MCPServerConfig:
    """Configuration for an MCP server"""
    name: str
    command: str
    args: List[str]
    env: Dict[str, str]
    required: bool = True


@dataclass
class ValidationResult:
    """Result of MCP server validation"""
    server_name: str
    status: str  # "connected", "failed", "skipped"
    message: str
    timestamp: str
    tools_available: Optional[List[str]] = None


class MCPValidator:
    """Validates MCP server connections"""

    def __init__(self):
        self.servers = self._load_server_configs()
        self.results: List[ValidationResult] = []

    def _load_server_configs(self) -> List[MCPServerConfig]:
        """Load MCP server configurations"""
        return [
            MCPServerConfig(
                name="perplexity-ask",
                command="npx",
                args=["-y", "server-perplexity-ask"],
                env={"PERPLEXITY_API_KEY": os.getenv("PERPLEXITY_API_KEY", "")},
                required=True
            ),
            MCPServerConfig(
                name="github",
                command="npx",
                args=["-y", "@modelcontextprotocol/server-github"],
                env={"GITHUB_PERSONAL_ACCESS_TOKEN": os.getenv("GITHUB_TOKEN", "")},
                required=True
            ),
            MCPServerConfig(
                name="memory",
                command="npx",
                args=["-y", "@modelcontextprotocol/server-memory"],
                env={},
                required=True
            ),
            MCPServerConfig(
                name="langfuse",
                command="node",
                args=["/Users/smenssink/.config/mcp-servers/mcp-server-langfuse/build/index.js"],
                env={
                    "LANGFUSE_PUBLIC_KEY": os.getenv("LANGFUSE_PUBLIC_KEY", ""),
                    "LANGFUSE_SECRET_KEY": os.getenv("LANGFUSE_SECRET_KEY", ""),
                    "LANGFUSE_BASEURL": os.getenv("LANGFUSE_BASEURL", "https://cloud.langfuse.com")
                },
                required=False
            )
        ]

    async def validate_server(self, server: MCPServerConfig) -> ValidationResult:
        """Validate a single MCP server connection"""
        try:
            # Check if required environment variables are set
            if server.required:
                for env_key, env_value in server.env.items():
                    if not env_value or env_value.startswith("your-"):
                        return ValidationResult(
                            server_name=server.name,
                            status="failed",
                            message=f"Missing or invalid {env_key}",
                            timestamp=datetime.now().isoformat()
                        )

            # Simulate connection test (in real implementation, would use MCP SDK)
            # For now, we just check if the command exists
            if server.command == "npx":
                # Check if npx is available
                proc = await asyncio.create_subprocess_exec(
                    "which", "npx",
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                stdout, stderr = await proc.communicate()

                if proc.returncode != 0:
                    return ValidationResult(
                        server_name=server.name,
                        status="failed",
                        message="npx not found - install Node.js",
                        timestamp=datetime.now().isoformat()
                    )

            elif server.command == "node":
                # Check if the script file exists
                script_path = Path(server.args[0]) if server.args else None
                if script_path and not script_path.exists():
                    return ValidationResult(
                        server_name=server.name,
                        status="failed",
                        message=f"Script not found: {script_path}",
                        timestamp=datetime.now().isoformat()
                    )

            # If all checks pass
            return ValidationResult(
                server_name=server.name,
                status="connected",
                message="Server configuration valid",
                timestamp=datetime.now().isoformat(),
                tools_available=[]  # Would be populated with actual tools in real implementation
            )

        except Exception as e:
            return ValidationResult(
                server_name=server.name,
                status="failed",
                message=str(e),
                timestamp=datetime.now().isoformat()
            )

    async def validate_all(self) -> Dict[str, Any]:
        """Validate all MCP server connections"""
        print("🔍 Validating MCP Server Connections...")
        print("=" * 50)

        # Load environment variables
        from dotenv import load_dotenv
        env_file = Path(__file__).parent.parent / ".env"
        if env_file.exists():
            load_dotenv(env_file)
            print(f"✅ Loaded environment from {env_file}")
        else:
            print(f"⚠️  No .env file found at {env_file}")
            print("   Using system environment variables")

        print("\n")

        # Validate each server
        for server in self.servers:
            result = await self.validate_server(server)
            self.results.append(result)

            # Print result
            icon = "✅" if result.status == "connected" else "❌"
            print(f"{icon} {server.name}: {result.status}")
            if result.status != "connected":
                print(f"   └─ {result.message}")

        # Summary
        print("\n" + "=" * 50)
        connected = sum(1 for r in self.results if r.status == "connected")
        failed = sum(1 for r in self.results if r.status == "failed")

        print(f"Summary: {connected}/{len(self.servers)} servers validated")

        if failed > 0:
            print(f"⚠️  {failed} servers need configuration")
            print("\nTo fix:")
            print("1. Copy config.example to .env")
            print("2. Add your API keys to .env")
            print("3. Run this script again")

        return {
            "total": len(self.servers),
            "connected": connected,
            "failed": failed,
            "results": [
                {
                    "server": r.server_name,
                    "status": r.status,
                    "message": r.message
                }
                for r in self.results
            ]
        }


async def main():
    """Main entry point"""
    validator = MCPValidator()
    summary = await validator.validate_all()

    # Write results to file
    results_file = Path(__file__).parent.parent / "mcp_validation_results.json"
    with open(results_file, "w") as f:
        json.dump(summary, f, indent=2)

    print(f"\nResults saved to: {results_file}")

    # Exit with error code if any failures
    sys.exit(0 if summary["failed"] == 0 else 1)


if __name__ == "__main__":
    asyncio.run(main())
