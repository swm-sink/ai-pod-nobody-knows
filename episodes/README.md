# Episodes Directory

## Organization

- **`completed/`** - Finished episodes ready for distribution
- **`in_progress/`** - Episodes currently being worked on (created dynamically)
- **`templates/`** - Templates for new episode creation

## No Pre-Creation Policy

Episodes are created dynamically when work begins, not in advance. This prevents:
- File system bloat
- Premature optimization 
- Management overhead
- Confusion about actual vs planned content

## Creating New Episodes

Episodes are created automatically by the podcast workflow when you run:
```
/podcast "Your Topic Name"
```

This will:
1. Create `episodes/in_progress/episode-XXX/` directory
2. Initialize with proper metadata
3. Track progress through research → script → audio → quality → completed
4. Move to `episodes/completed/` when finished

## Finding Completed Episodes

Completed episodes can be found in:
- `episodes/completed/` - Final organized episodes
- `sessions/` - Raw production sessions (legacy organization)

The `sessions/` directory contains the original working files and may eventually be archived.