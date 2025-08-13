# Output Directory Policy

This directory holds generated artifacts from the production pipeline:

- `audio/` final audio files
- `research/` research packages
- `scripts/` episode scripts
- `quality/` evaluation reports
- `sessions/` session state

Policy:
- Generated artifacts are generally not committed.
- Small illustrative samples may be committed to document formats.
- For full runs, outputs should be excluded from commits (root `.gitignore` already covers audio/output patterns).
