# Documentation Navigation Context
<!-- Context Level: Domain | Inherits: Project Root | Token Budget: 1K -->

## 📚 DOCUMENTATION STRUCTURE

**Purpose**: Learning resources and system documentation
**Organization**: Progressive complexity levels
**Format**: Markdown with examples and diagrams

## 🗺️ DOCUMENTATION MAP

### Getting Started
```
docs/
├── README.md                    # Project overview
├── GETTING_STARTED.md          # Quick start guide
├── ARCHITECTURE.md             # System design
└── (.claude/context/02_walk_crawl_run_phases.md)  # Learning progression
```

### Production Guides
```
docs/production/
├── SETUP_GUIDE.md              # Environment setup
├── PRODUCTION_CHECKLIST.md    # Pre-production validation
├── DEPLOYMENT.md               # Production deployment
└── MONITORING.md               # Observability setup
```

### Development Docs
```
docs/development/
├── AGENT_DEVELOPMENT.md        # Creating new agents
├── WORKFLOW_PATTERNS.md        # LangGraph patterns
├── TESTING_GUIDE.md           # Test development
└── CONTRIBUTING.md            # Contribution guidelines
```

### Reports & Analysis
```
docs/reports/
├── PRODUCTION_METRICS.md       # Episode statistics
├── COST_ANALYSIS.md           # Budget breakdown
├── QUALITY_REPORT.md          # Quality metrics
└── LESSONS_LEARNED.md         # Retrospectives
```

## 📖 KEY DOCUMENTS

### ARCHITECTURE.md
- System overview
- Component interactions
- Data flow diagrams
- Technology stack

### PRODUCTION_SETUP_GUIDE.md
- API key configuration
- Environment setup
- Dependency installation
- Validation steps

### AGENT_DEVELOPMENT.md
- Agent interface
- State management
- Error handling
- Testing patterns

## 🎓 LEARNING PATHS

### Beginner Path
1. `README.md` - Understand the mission
2. `GETTING_STARTED.md` - First steps
3. `.claude/context/02_walk_crawl_run_phases.md` - Progressive learning
4. Run first dry-run episode

### Intermediate Path
1. `ARCHITECTURE.md` - System design
2. `WORKFLOW_PATTERNS.md` - LangGraph
3. `TESTING_GUIDE.md` - Quality assurance
4. Produce first real episode

### Advanced Path
1. `AGENT_DEVELOPMENT.md` - Build agents
2. `PERFORMANCE_OPTIMIZATION.md` - Tuning
3. `DEPLOYMENT.md` - Production ops
4. Contribute improvements

## 📊 REFERENCE MATERIALS

### API Documentation
- [Perplexity API](https://docs.perplexity.ai)
- [ElevenLabs API](https://docs.elevenlabs.io)
- [LangGraph Docs](https://python.langchain.com/docs/langgraph)
- [Claude MCP](https://docs.anthropic.com/mcp)

### Best Practices
- September 2025 async patterns
- LangGraph orchestration
- Cost optimization strategies
- Quality gate implementation

## 🔍 QUICK REFERENCE

### Common Commands
```bash
# System validation
python validate_production_readiness.py
python check_health.py

# Episode production
python main.py --topic "Topic" --budget 5.51
python main.py --topic "Topic" --dry-run

# Testing
pytest tests/ -v
./tests/quality_gates/run_all.sh
```

### Troubleshooting
- Check `docs/troubleshooting/COMMON_ISSUES.md`
- Review error logs in `logs/`
- Validate API keys with `check_setup.py`
- Test MCP connections: `claude mcp list`

## 📈 METRICS & REPORTS

### Production Metrics
- Episodes produced: 125+
- Average cost: $5.51
- Success rate: 95%
- Quality score: 8.5/10

### Documentation Coverage
- API coverage: 100%
- Agent documentation: 100%
- Workflow patterns: 95%
- Troubleshooting: 90%

## 🔄 INHERITANCE

**Inherits From**: `/CLAUDE.md` (Project Root)
**References**:
- Production guides → `@podcast_production/CLAUDE.md`
- Agent docs → `@.claude/agents/CLAUDE.md`
- Testing docs → `@tests/CLAUDE.md`

---

**Token Budget**: 1K | **Focus**: Documentation navigation | **Status**: Reference