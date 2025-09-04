# AI Podcast Production System - Makefile
# Common development and production commands

.PHONY: help install test lint format clean health setup-dev run-tests deploy

# Default target
help:
	@echo "AI Podcast Production System - Available Commands:"
	@echo ""
	@echo "Development:"
	@echo "  install     Install dependencies and setup environment"
	@echo "  setup-dev   Setup development environment with pre-commit hooks"
	@echo "  health      Check system health and API connections"
	@echo "  format      Format code with black and ruff"
	@echo "  lint        Run linting and code quality checks"
	@echo "  clean       Clean cache, logs, and temporary files"
	@echo ""
	@echo "Testing:"
	@echo "  test        Run full test suite"
	@echo "  test-unit   Run unit tests only"
	@echo "  test-integration Run integration tests only"
	@echo "  test-e2e    Run end-to-end tests"
	@echo "  coverage    Run tests with coverage report"
	@echo ""
	@echo "Production:"
	@echo "  episode     Create a podcast episode (requires TOPIC variable)"
	@echo "  research    Research a topic (requires TOPIC variable)"
	@echo "  validate    Validate production readiness"
	@echo "  archive     Archive old episodes"
	@echo ""
	@echo "Examples:"
	@echo "  make episode TOPIC='Why do we dream?'"
	@echo "  make research TOPIC='Quantum physics basics'"

# Development commands
install:
	pip install -r requirements.txt
	pip install -e .

setup-dev: install
	pip install pre-commit black ruff pytest pytest-cov
	pre-commit install

health:
	python check_health.py

format:
	black src/ tests/ podcast_production/
	ruff --fix src/ tests/ podcast_production/

lint:
	black --check src/ tests/ podcast_production/
	ruff check src/ tests/ podcast_production/
	mypy src/ podcast_production/

clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -name "*.log" -type f -mtime +7 -delete
	find . -type d -empty -delete

# Testing commands
test:
	pytest tests/ -v --tb=short

test-unit:
	pytest tests/unit/ -v

test-integration:
	pytest tests/integration/ -v

test-e2e:
	pytest tests/e2e/ -v

coverage:
	pytest tests/ --cov=src --cov=podcast_production --cov-report=html --cov-report=term

# Production commands
episode:
	@if [ -z "$(TOPIC)" ]; then \
		echo "Error: TOPIC variable required. Usage: make episode TOPIC='Your topic here'"; \
		exit 1; \
	fi
	cd podcast_production && python main.py --topic "$(TOPIC)" --budget 5.51

research:
	@if [ -z "$(TOPIC)" ]; then \
		echo "Error: TOPIC variable required. Usage: make research TOPIC='Your topic here'"; \
		exit 1; \
	fi
	cd podcast_production && python main.py --topic "$(TOPIC)" --research-only

validate:
	python check_health.py
	cd podcast_production && python validate_production_readiness.py

archive:
	cd episodes && python archive_episodes.py

# Development workflow
dev-setup: clean setup-dev health
	@echo "Development environment ready!"
	@echo "Run 'make health' to verify all APIs are working"
	@echo "Run 'make episode TOPIC=\"test topic\"' to create your first episode"

# CI/CD workflow
ci: lint test coverage
	@echo "All CI checks passed!"

# Quick start for new users
quick-start:
	@echo "Setting up AI Podcast Production System..."
	@make install
	@echo ""
	@echo "Next steps:"
	@echo "1. Copy .env.example to .env and add your API keys"
	@echo "2. Run 'make health' to verify setup"
	@echo "3. Run 'make episode TOPIC=\"Why do cats purr?\"' for your first episode"
	@echo ""
	@echo "For detailed setup instructions, see docs/user-guides/USER_GETTING_STARTED.md"