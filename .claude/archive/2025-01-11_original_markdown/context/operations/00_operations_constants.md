<document type="constants" version="3.1.0" enhanced="2025-08-11">
  <metadata>
    <title>Operations Constants - Production Operations and System Management</title>
    <scope>operations-domain</scope>
    <category>operations</category>
    <mutability>read-only</mutability>
    <validation-frequency>weekly</validation-frequency>
    <navigation>
      <index>@NAVIGATION.md</index>
      <related>@../../00_GLOBAL_CONSTANTS.md</related>
    </navigation>
  </metadata>

  <summary>
    Central repository for production operations constants, environment configurations, and system management values.
    Single source of truth for all operations documentation to prevent duplication and ensure consistency.
  </summary>
</document>

# Operations Constants

## Overview

<purpose>
  This file contains all constants, commands, and configuration values for production operations and system management.
  All operations documentation should reference these values rather than hardcoding them.
</purpose>

---

## 🔧 Environment Configuration

```yaml
PYTHON_ENVIRONMENT:
  version: "3.11+"
  virtual_env: "venv"
  package_manager: "pip"
  requirements_file: "requirements.txt"

ACTIVATION_COMMANDS:
  unix_linux_mac: "source venv/bin/activate"
  windows: "venv\\Scripts\\activate"
  deactivate: "deactivate"

COMMON_DEPENDENCIES:
  framework: "fastapi"
  server: "uvicorn"
  testing: "pytest"
  formatting: "black"
  linting: "ruff"
  requests: "httpx"
  environment: "python-dotenv"
```

---

## 🚀 Server Operations

```yaml
SERVER_COMMANDS:
  start_dev: "uvicorn core.orchestration.server:app --reload"
  start_prod: "uvicorn core.orchestration.server:app --host 0.0.0.0 --port 8000"
  stop: "Ctrl+C"
  restart: "Kill and restart process"

SERVER_CONFIG:
  host_dev: "localhost"
  host_prod: "0.0.0.0"
  port: 8000
  reload: true  # Dev only
  workers: 1    # Increase for production

ENDPOINTS:
  api_root: "http://localhost:8000"
  docs: "http://localhost:8000/docs"
  redoc: "http://localhost:8000/redoc"
  health: "http://localhost:8000/health"
```

---

## 📊 Monitoring and Logging

```yaml
LOG_LEVELS:
  debug: "Detailed debugging information"
  info: "General information"
  warning: "Warning messages"
  error: "Error conditions"
  critical: "Critical failures"

LOG_FILES:
  application: "logs/app.log"
  error: "logs/error.log"
  access: "logs/access.log"
  costs: "logs/costs.log"
  quality: "logs/quality.log"

MONITORING_COMMANDS:
  tail_logs: "tail -f logs/*.log"
  check_costs: 'grep "Cost:" logs/costs.log | tail -10'
  error_count: 'grep -c "ERROR" logs/error.log'
  disk_usage: "du -sh logs/"
```

---

## 🔍 Troubleshooting

```yaml
COMMON_ISSUES:
  port_in_use:
    error: "Address already in use"
    solution: "Kill process on port 8000"
    command: "lsof -ti:8000 | xargs kill -9"

  dependencies_missing:
    error: "ModuleNotFoundError"
    solution: "Install requirements"
    command: "pip install -r requirements.txt"

  virtual_env_inactive:
    error: "Command not found"
    solution: "Activate virtual environment"
    command: "source venv/bin/activate"

  api_key_missing:
    error: "Unauthorized"
    solution: "Check .env file"
    command: "cp .env.example .env"

DEBUG_COMMANDS:
  check_python: "python --version"
  check_pip: "pip --version"
  list_packages: "pip list"
  check_env: "echo $VIRTUAL_ENV"
  test_server: "curl http://localhost:8000/health"
```

---

## 📋 Operational Checklists

```yaml
STARTUP_CHECKLIST:
  - "Virtual environment activated"
  - "Dependencies installed"
  - "Environment variables set"
  - "Port 8000 available"
  - "Server starts without errors"
  - "API documentation accessible"

DEPLOYMENT_CHECKLIST:
  - "All tests passing"
  - "Code linted and formatted"
  - "Environment variables configured"
  - "Logs directory exists"
  - "Health check endpoint working"
  - "Production settings applied"

MAINTENANCE_CHECKLIST:
  - "Log files rotated"
  - "Disk space sufficient"
  - "Dependencies updated"
  - "Security patches applied"
  - "Backup verified"
  - "Performance metrics reviewed"
```

---

## 💰 Cost Management

```yaml
COST_TRACKING:
  log_file: "logs/costs.log"
  format: "ISO_DATE | SERVICE | OPERATION | COST | DETAILS"
  frequency: "Every API call"
  aggregation: "Daily, weekly, monthly"

COST_ALERTS:
  daily_limit: "$10"
  weekly_limit: "$50"
  monthly_limit: "$200"
  episode_limit: "$8"

COST_OPTIMIZATION:
  caching: "Reuse common audio segments"
  batching: "Process multiple requests together"
  model_selection: "Use cost-appropriate models"
  monitoring: "Track all API usage"
```

---

## 🔐 Security Operations

```yaml
ENVIRONMENT_SECURITY:
  api_keys: "Never commit to version control"
  env_file: ".env in .gitignore"
  template: ".env.example for reference"
  rotation: "Regular key rotation"

ACCESS_CONTROL:
  local_only: "Development on localhost"
  auth_required: "Production environments"
  https_only: "Secure connections"
  input_validation: "Sanitize all inputs"

SECURITY_CHECKLIST:
  - "API keys in environment variables"
  - ".env file not committed"
  - "Input validation implemented"
  - "HTTPS enabled (production)"
  - "Dependencies vulnerability-free"
  - "Logs don't contain secrets"
```

---

## 🔄 Backup and Recovery

```yaml
BACKUP_STRATEGY:
  frequency: "Daily automated"
  retention: "30 days local, 90 days cloud"
  scope: "Code, configuration, logs, data"
  validation: "Weekly restore test"

RECOVERY_PROCEDURES:
  data_loss:
    step_1: "Stop all services"
    step_2: "Restore from backup"
    step_3: "Verify data integrity"
    step_4: "Resume operations"

  system_failure:
    step_1: "Check system status"
    step_2: "Restart failed services"
    step_3: "Verify connectivity"
    step_4: "Resume normal operation"
```

---

## 📈 Performance Metrics

```yaml
PERFORMANCE_TARGETS:
  response_time: "< 5 seconds"
  uptime: "> 99%"
  throughput: "10 episodes/hour"
  error_rate: "< 1%"

MONITORING_INTERVALS:
  real_time: "Error alerts"
  hourly: "Performance metrics"
  daily: "Cost summaries"
  weekly: "Trend analysis"

PERFORMANCE_COMMANDS:
  cpu_usage: "top"
  memory_usage: "free -h"
  disk_usage: "df -h"
  network_stats: "netstat -i"
```

---

## 🔧 Development Tools

```yaml
FORMATTING:
  tool: "black"
  command: "black ."
  config: "pyproject.toml"

LINTING:
  tool: "ruff"
  command: "ruff check ."
  fix: "ruff check . --fix"

TESTING:
  framework: "pytest"
  command: "pytest tests/"
  coverage: "pytest --cov=core tests/"
  markers: "pytest -m unit"

TYPE_CHECKING:
  tool: "mypy"
  command: "mypy core/"
  config: "mypy.ini"
```

---

## 📁 File Management

```yaml
IMPORTANT_FILES:
  main_config: "CLAUDE.md"
  environment: ".env"
  dependencies: "requirements.txt"
  server: "core/orchestration/server.py"

GENERATED_FILES:
  episodes: "projects/episodes/"
  logs: "logs/"
  cache: "cache/"
  temp: "tmp/"

FILE_PATTERNS:
  ignore: ".claudeignore"
  env_template: ".env.example"
  log_rotation: "*.log.{date}"
  backup: "backup_{timestamp}.tar.gz"
```

---

## 🔗 Cross-References

- **Global Constants**: [00_GLOBAL_CONSTANTS.md](../../00_GLOBAL_CONSTANTS.md)
- **Foundation**: [foundation/00_project_constants.md](../foundation/00_project_constants.md)
- **Quality**: [quality/00_quality_constants.md](../quality/00_quality_constants.md)
- **Troubleshooting Guide**: [08_troubleshooting_guide.md](./08_troubleshooting_guide.md)
- **Production Checklist**: [10_production_checklist.md](./10_production_checklist.md)

---

*Version 1.0.0 - Single source of truth for operations and system management*
