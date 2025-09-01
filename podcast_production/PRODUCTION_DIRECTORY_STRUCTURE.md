# Production Directory Structure
Generated: 2025-09-01T09:49:35.555717+00:00

## Directory Layout

```
podcast_production/
├── logs/                    # System and application logs
│   ├── health_checks/      # Health check results
│   └── production.log      # Main production log
├── output/                 # Episode output files
├── audio_output/           # Generated audio files
├── research_data/          # Research and planning data
├── production_validation_output/ # Validation reports
├── monitoring/             # Monitoring configurations
└── backup/                 # Backup configurations and scripts
```

## Usage Notes

- All directories are created during production setup
- Logs rotate automatically based on config.yaml settings
- Backup directory contains automated backup scripts
- Monitoring directory contains dashboard and alerting configs
