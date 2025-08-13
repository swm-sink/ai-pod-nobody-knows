# Output Artifacts Policy

This directory stores locally generated audio artifacts for testing and demos.

- Do not commit large audio files by default.
- Short sample artifacts (<=1 MB) may be committed for documentation/testing.
- For real production runs, keep outputs untracked and archive externally.

To ignore outputs locally, ensure patterns exist in the root `.gitignore` (already includes audio and output directories).
