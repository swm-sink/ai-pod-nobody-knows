# Episodes Directory - Organized Episode Management

This directory separates test content from production content for clean organization.

## Structure

```
episodes/
├── README.md               # This file
├── state.json             # Master state file for all episodes
├── metrics_history.csv    # Time-series metrics data
├── dashboard.py           # Streamlit monitoring dashboard
├── test/                  # Test and validation episodes
│   ├── validation_episodes_2_3/    # Episodes 2&3 validation testing
│   ├── quantum_computing/          # Original test episode
│   └── system_tests/              # System validation tests
├── production/            # Production episodes (125 episodes)
│   ├── ep001/            # Episode 1
│   │   ├── status.json   # Episode status
│   │   ├── research/     # Research outputs
│   │   ├── production/   # Production outputs
│   │   └── metrics.json  # Cost and quality metrics
│   ├── ep002/            # Episode 2
│   └── ...ep125/         # Episodes 3-125
└── archive/              # Archived/old sessions
```

## Episode Types

### Test Episodes
- **Purpose**: System validation, testing workflows, quality assurance
- **Location**: `episodes/test/`
- **Characteristics**: Non-production, testing purposes only

### Production Episodes
- **Purpose**: Real podcast episodes for release
- **Location**: `episodes/production/`
- **Characteristics**: 125 episodes, production-ready content

## Commands

- `/episodes status` - Show overall progress
- `/episodes research 1-10` - Research episodes 1-10
- `/episodes dashboard` - Launch monitoring dashboard
- `/episode-status 1` - Check specific episode

## Status Indicators

- ⚪ not_started - Nothing done yet
- 🔵 researching - Research in progress
- 🟡 researched - Research complete
- 🟠 producing - Production in progress
- 🟣 validating - Quality validation
- 🟢 complete - Ready for delivery
- 🔴 failed - Error occurred
