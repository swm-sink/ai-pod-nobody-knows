# .claude Directory - Project Infrastructure

Simple infrastructure overview for the AI Podcasts project using Claude Code.

## Directory Structure

```
.claude/
├── agents/                # AI agents for podcast production
│   ├── research/          # 3 research agents
│   ├── production/        # 10 production agents
│   └── research-synthesizer.md # Bridge agent
├── commands/              # Slash commands
├── config/                # Configuration files
├── context/               # Documentation
└── shared/                # Templates
```

## Two-Stream Architecture

**Research Stream**: Topic → Research → Questions → Synthesis
**Production Stream**: Knowledge → Planning → Script → Quality → Audio

## Key Principles

- Minimum viable complexity
- Claude Code native integration
- Direct agent invocation via Task tool
- Simple session management
- Clear cost tracking

## Navigation

- `/produce-research "topic"` - Start research stream
- `/produce-episode path` - Start production stream  
- `/test-episode "topic"` - Simple pipeline test

## Learning Value

This teaches AI orchestration through practical podcast production, emphasizing:
- Agent specialization and coordination
- Quality gate implementation  
- Cost-effective AI workflows
- Production pipeline design

Simple, effective, and educational.