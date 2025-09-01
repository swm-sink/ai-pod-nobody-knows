# LangGraph Migration - AI Podcast Production System

Modern, modular podcast production system built on LangGraph orchestration framework.

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Test with dry run (no API calls)
python3 main.py --topic "Why do we dream?" --dry-run --verbose

# Production run (requires API keys)
python3 main.py --topic "Why do we dream?" --budget 5.51

# Custom output directory
python3 main.py --topic "Quantum Computing" --output-dir "./episodes" --budget 10.00
```

## Command Line Options

- `--topic`: Episode topic (required)
- `--budget`: Maximum budget in USD (default: $5.51)
- `--output-dir`: Output directory (default: ./output)
- `--dry-run`: Run without API calls for testing
- `--verbose`: Enable debug logging
- `--save-state`: Save final workflow state to JSON

## Architecture

- **main.py**: CLI entry point and orchestration
- **src/core/state.py**: Central state management with TypedDict
- **src/workflows/main_workflow.py**: LangGraph workflow definition
- **src/agents/**: Individual agent implementations
- **config/providers.yaml**: Provider configurations

## Environment Variables

Required for production runs:
- `PERPLEXITY_API_KEY`: For research stages
- `LANGFUSE_PUBLIC_KEY`: For observability
- `LANGFUSE_SECRET_KEY`: For observability
- `OPENAI_API_KEY`: For content generation
- `ELEVENLABS_API_KEY`: For audio synthesis

## Current Status

✅ Basic orchestration structure complete
✅ CLI interface functional
✅ State management implemented
✅ LangGraph workflow defined
✅ Mock execution working

🚧 In Progress:
- Individual agent migrations
- Full API integrations
- Audio generation pipeline
- Quality validation system

## Testing

```bash
# Run basic dry-run test
python3 main.py --topic "Test" --dry-run

# Test with verbose logging
python3 main.py --topic "Test" --dry-run --verbose

# Test configuration loading
python3 -c "from src.core.config.manager import get_config_manager; print('Config OK')"
```

## Cost Performance

Target: $5.51 per episode (vs traditional $800-3500)
Current: $0.00 (dry-run mode functional)

Built for the AI Podcast Production Master System - August 2025
