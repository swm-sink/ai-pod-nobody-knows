<document type="project-documentation" version="2.0.0">
  <metadata>
    <project-name>AI Podcasts - Nobody Knows</project-name>
    <last-updated>2025-08-10</last-updated>
    <requires-approval>true</requires-approval>
    <validation-status>updated-for-tdd-rebuild</validation-status>
  </metadata>

  <change-approval-notice>
    <critical>
      ANY modifications to this project documentation require:
      1. User explicit approval BEFORE changes
      2. AI detailed impact assessment
      3. Validation through technical verification
      4. User confirmation AFTER implementation
    </critical>
  </change-approval-notice>

# AI Podcasts - Nobody Knows 🎙️

<project-overview>
  <description>
    A hobbyist learning project for mastering AI agent orchestration by building 
    an automated podcast production system. Designed to create the "Nobody Knows" 
    100-episode educational podcast series while teaching AI concepts through 
    practical application.
  </description>
  
  <target-audience>Individual hobbyist learners (not enterprise)</target-audience>
  <approach>Progressive learning through hands-on podcast creation</approach>
</project-overview>

## 🌟 Features

- **Multi-Project Architecture**: Supports multiple podcast series with isolated configurations
- **AI Agent Orchestration**: Coordinates specialized agents for research, writing, and synthesis
- **Cross-Project Learning**: ChromaDB-powered memory system for pattern recognition and optimization
- **Quality-Driven Production**: Automated quality evaluation with customizable thresholds
- **Cost-Efficient**: Optimized to produce episodes at ~$8 each using AI APIs
- **Brand Voice Consistency**: Intellectual humility and engaging educational content
- **FastAPI Integration**: RESTful API for production management and monitoring

## 🏗️ Architecture

```
ai-podcasts-nobody-knows/
├── .claude/                 # Claude Code configuration
│   ├── CLAUDE.md           # System documentation for Claude
│   └── context/           # 14 learning context files
├── core/                   # Shared infrastructure (DELETED - TDD rebuild needed)
│   ├── agents/            # AI agent implementations (to be rebuilt)
│   ├── orchestration/     # Workflow management (to be rebuilt)
│   └── memory/            # ChromaDB integration (to be rebuilt)
├── projects/              # Project-specific configurations
│   └── nobody-knows/      # Primary podcast project
├── shared/                # Shared resources
└── requirements.txt       # Python dependencies
```

<current-status>
  <code-status>All Python code deleted for TDD rebuild</code-status>
  <documentation-status>Enhanced with XML semantic tagging</documentation-status>
  <learning-phase>WALK - No API keys needed</learning-phase>
</current-status>

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- API keys for:
  - Anthropic (Claude)
  - Perplexity
  - ElevenLabs
  - OpenAI (optional)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/ai-podcasts-nobody-knows.git
cd ai-podcasts-nobody-knows
```

2. **Create virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your API keys
```

5. **Start the FastAPI server**
```bash
uvicorn core.orchestration.server:app --reload
```

The API will be available at `http://localhost:8000`

## 📝 Usage

### Creating a Project

```bash
curl -X POST http://localhost:8000/projects \
  -H "Content-Type: application/json" \
  -d '{
    "project_name": "my-podcast",
    "project_type": "long_series",
    "episode_duration": 27
  }'
```

### Producing an Episode

```bash
curl -X POST http://localhost:8000/produce/episode \
  -H "Content-Type: application/json" \
  -d '{
    "project_name": "nobody-knows",
    "topic": "The Nature of Consciousness",
    "episode_number": 1,
    "complexity_level": "intermediate"
  }'
```

### Batch Production

```bash
curl -X POST http://localhost:8000/produce/batch \
  -H "Content-Type: application/json" \
  -d '{
    "project_name": "nobody-knows",
    "episodes": [
      {"topic": "Topic 1", "episode_number": 1},
      {"topic": "Topic 2", "episode_number": 2}
    ]
  }'
```

## 🤖 Claude Code Commands

When using Claude Code, you have access to custom commands:

- `/project:create [name] [type] [duration]` - Create new project
- `/autoproduce [project] [topic] [episode_number]` - Produce single episode
- `/batch:produce [project] [csv_file]` - Batch production from CSV
- `/quality:check [project] [episode_file]` - Evaluate episode quality
- `/system:optimize [focus_area]` - Run cross-project optimization

## 🎯 The "Nobody Knows" Project

The flagship project is a 100-episode educational podcast series featuring:

### Season Structure (10 episodes each)
1. **Foundations of Knowledge** - Epistemology and learning
2. **The Natural World** - Physics, chemistry, earth sciences
3. **Human Mind and Behavior** - Psychology and neuroscience
4. **Technology and Innovation** - Computing and engineering
5. **Society and Culture** - Anthropology and sociology
6. **The Universe and Beyond** - Astronomy and cosmology
7. **Life Sciences** - Biology and evolution
8. **Philosophy and Ethics** - Moral questions and reasoning
9. **Future Frontiers** - Emerging sciences and possibilities
10. **Synthesis and Reflection** - Connecting all themes

### Quality Standards
- **Comprehension**: ≥ 0.85 (Clear explanations)
- **Brand Consistency**: ≥ 0.90 (Intellectual humility)
- **Engagement**: ≥ 0.80 (Maintains interest)
- **Technical**: ≥ 0.85 (Proper structure)

## 🔧 Configuration

### Project Configuration
Each project has its own configuration in `projects/[name]/config/`:
- `project_config.json` - Main settings
- `brand_voice.md` - Voice and tone guidelines
- `quality_gates.json` - Quality thresholds
- `episode_structure.md` - Episode format template

### Environment Variables
Key settings in `.env`:
```env
ANTHROPIC_API_KEY=your_key
PERPLEXITY_API_KEY=your_key
ELEVENLABS_API_KEY=your_key
CHROMA_PERSIST_DIRECTORY=./chroma_db
MAX_COST_PER_EPISODE=8.00
```

## 📊 Monitoring

### API Endpoints
- `GET /health` - System health check
- `GET /status` - Overall system status
- `GET /projects` - List all projects
- `GET /production/{task_id}/status` - Production task status

### Cost Tracking
The system tracks costs per episode:
- Research: ~$5.00 (Perplexity)
- Script Writing: ~$1.00 (Claude)
- Audio Synthesis: ~$2.00 (ElevenLabs v3)
- **Total Target**: $8.00 per episode

## 🧠 AI Agents

### Research Coordinator
- Uses Perplexity API for comprehensive research
- Manages multiple information sources
- Caches results for efficiency

### Script Writer
- Generates brand-consistent scripts
- Applies intellectual humility principles
- Ensures progressive complexity

### Audio Synthesizer
- Integrates with ElevenLabs v3
- Natural conversation generation
- Cost-optimized with 80% discount (through June 2025)

### Quality Evaluator
- Validates against quality thresholds
- Provides improvement recommendations
- Ensures brand consistency

## 🔄 Development Workflow

### Phase 1: Walk (Foundation)
✅ Project structure setup
✅ Agent architecture implementation
✅ FastAPI server creation
✅ ChromaDB integration

### Phase 2: Crawl (Single Project)
✅ "Nobody Knows" configuration
✅ Episode production pipeline
✅ Quality evaluation system
✅ Cost tracking

### Phase 3: Run (Multi-Project)
- Cross-project optimization
- Batch production optimization
- Advanced monitoring dashboard
- Production deployment

## 🧪 Testing

Run tests with:
```bash
pytest tests/ -v
```

Format and lint code:
```bash
black . && ruff check .
```

## 📈 Performance

- **Production Time**: ~5-10 minutes per episode
- **Quality Score**: Average 0.88/1.0
- **Cost Efficiency**: $8 per 27-minute episode
- **Scalability**: Handles multiple projects concurrently

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with Claude Code assistance
- Powered by Anthropic, Perplexity, and ElevenLabs APIs
- Inspired by the pursuit of knowledge with intellectual humility

## 📞 Support

For questions or issues:
- Open an issue on GitHub
- Check the documentation in `.claude/CLAUDE.md`
- Review the API documentation at `/docs` when server is running

---

*"Nobody knows everything, but together we can learn anything."*

<validation-notes>
  <documentation-update>
    README updated to reflect current hobbyist learning focus 
    and TDD code deletion as of 2025-08-10
  </documentation-update>
  
  <architecture-status>
    Architecture diagrams updated to show deleted code status 
    and need for TDD rebuild
  </architecture-status>
</validation-notes>

</document>