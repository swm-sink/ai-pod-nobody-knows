# 🤝 Contributing to AI Podcasts Nobody Knows

First off, thank you for considering contributing to this educational project! This is a learning-focused initiative, and we value contributions that help others understand AI orchestration better.

## 📋 Table of Contents
- [Our Philosophy](#our-philosophy)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Process](#development-process)
- [Code Standards](#code-standards)
- [Pull Request Process](#pull-request-process)
- [Educational Requirements](#educational-requirements)
- [Community Guidelines](#community-guidelines)

## 🎯 Our Philosophy

**"Nobody Knows"** - We celebrate intellectual humility. We value questions as much as answers, learning as much as teaching, and clarity over cleverness.

**Core Values:**
- 🎓 **Education First**: Every contribution should teach something
- 🤝 **Intellectual Humility**: Admit what we don't know
- 📚 **Dual Explanations**: Technical AND simple explanations
- 🔄 **Iterative Learning**: Start simple, grow complex
- 💡 **Practical Application**: Learn by building real things

## 🚀 How Can I Contribute?

### For Beginners (WALK Phase)
- 📝 **Documentation**: Improve explanations, fix typos, add examples
- 🧪 **Testing**: Try the free activities and report issues
- 💭 **Questions**: Ask questions in issues - they help everyone learn
- 📖 **Tutorials**: Create learning guides from your experience

### For Intermediate (CRAWL Phase)
- 🐛 **Bug Fixes**: Fix issues and improve error messages
- 🔧 **Features**: Add small enhancements to existing agents
- 📊 **Examples**: Share your episode configurations and prompts
- 💰 **Cost Optimization**: Share tips for reducing API costs

### For Advanced (RUN Phase)
- 🤖 **New Agents**: Design and implement new specialized agents
- 🏗️ **Architecture**: Propose architectural improvements
- 🔄 **Integrations**: Add new MCP server integrations
- 📈 **Performance**: Optimize token usage and processing speed

## 🔄 Development Process

### 1. Start with an Issue
- Check existing issues or create a new one
- Discuss your idea before implementing
- Get feedback from the community

### 2. Fork and Branch
```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/[your-username]/ai-podcasts-nobody-knows.git
cd ai-podcasts-nobody-knows

# Create a feature branch
git checkout -b feature/your-feature-name
```

### 3. Make Your Changes
- Follow the [Code Standards](#code-standards)
- Include dual explanations (technical AND simple)
- Test your changes thoroughly
- Update documentation as needed

### 4. Test Your Changes
```bash
# Run validation scripts (from scripts/precommit/)
for script in scripts/precommit/*.sh; do
    bash "$script"
done

# Test with Claude Code
# Start Claude Code and run:
/produce-episode   # Test complete episode production

# Run pre-commit hooks
pre-commit run --all-files
```

### 5. Submit Pull Request
- Write clear commit messages following our format
- Create PR with detailed description
- Link to related issues
- Be patient and responsive to feedback

## 📐 Code Standards

### File Organization (Simplified v1.0)
```
.claude/                   # 54 files total (93% reduction achieved)
├── agents/               # 14 specialized agents
│   ├── research/         # 4 research agents
│   ├── production/       # 10 production agents
├── commands/             # 5 production commands
├── config/               # 5 essential configs
├── context/              # 10 core learning files
├── docs/                 # 8 essential docs
├── mcp-servers/          # 2 MCP setup files
└── shared/               # 5 essential templates
```

### Naming Conventions
- **Directories**: `lowercase-with-hyphens`
- **XML Files**: `lowercase_with_underscores.xml`
- **Agents**: `##_agent_name.md` (numbered with underscores)
- **Commands**: `verb-noun.md`

### Output File Locations

**IMPORTANT**: Never generate files in the root directory. Use these standard locations:

- **Documentation**: `.claude/docs/`
  - System documentation
  - Architecture guides
  - User guides

- **Configuration**: `.claude/config/`
  - Production configs
  - Quality gates
  - MCP settings

- **Temporary analysis**: `sessions/` (root level)
  - Session tracking
  - Production logs
  - Cost analysis

- **Session data**: `projects/nobody-knows/output/sessions/`
  - Episode production sessions
  - Pipeline state tracking

**Root Directory**: Reserved ONLY for:
- README.md, CONTRIBUTING.md, DEPLOYMENT.md
- LICENSE, CODE_OF_CONDUCT.md
- requirements.txt, dev-requirements.txt
- Configuration files (.gitignore, .pre-commit-config.yaml, etc.)

### Documentation Requirements

**EVERY contribution must include:**

```xml
<educational-value>
    <technical>
        Professional explanation with industry terminology
    </technical>
    <simple>
        Explanation using everyday analogies
    </simple>
    <connection>
        How this helps users learn AI orchestration
    </connection>
</educational-value>
```

### Commit Message Format
```
type(scope): description

- Detailed change 1
- Detailed change 2

Educational value: What this teaches users
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:
```
feat(agents): add sentiment analysis agent

- Implements new agent for emotional tone analysis
- Integrates with script polishing pipeline
- Adds configuration for sensitivity levels

Educational value: Teaches NLP integration and pipeline extension
```

## 📚 Educational Requirements

### The Feynman Rule
Every technical concept MUST have:
1. **Technical explanation** - Industry-standard terminology
2. **Simple explanation** - Like teaching a curious friend
3. **Practical example** - Real-world application
4. **Learning connection** - Transferable skills gained

### Example Documentation
```xml
<concept name="Token Optimization">
    <technical>
        Reducing token consumption through prompt compression,
        response caching, and model cascading strategies
    </technical>
    <simple>
        Like packing a suitcase efficiently - fitting more
        into less space while keeping everything you need
    </simple>
    <example>
        Cache research results to avoid repeated API calls,
        saving 42% on monthly costs
    </example>
    <connection>
        Teaches resource optimization applicable to any
        API-based system
    </connection>
</concept>
```

## 🔍 Pull Request Process

### PR Checklist
- [ ] Issue linked and discussed
- [ ] Code follows project standards
- [ ] Dual explanations included
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No sensitive data exposed
- [ ] Commit messages follow format
- [ ] PR description is detailed

### PR Template
```markdown
## Summary
Brief description of changes

## Related Issue
Fixes #(issue number)

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Educational Value
**Technical:** What industry concepts this demonstrates
**Simple:** Everyday analogy for the change
**Connection:** What users learn from this

## Testing
- [ ] Tested with mock data (WALK phase)
- [ ] Tested with real APIs (CRAWL phase)
- [ ] Tested at scale (RUN phase)

## Screenshots (if applicable)
Add screenshots or terminal output

## Checklist
- [ ] Follows code standards
- [ ] Includes dual explanations
- [ ] Updates documentation
- [ ] Adds tests if needed
```

## 🤝 Community Guidelines

### Be Respectful
- Welcome questions at all levels
- Explain without condescension
- Value different perspectives
- Admit when you don't know something

### Be Helpful
- Provide context with answers
- Share your learning journey
- Offer constructive feedback
- Help others debug issues

### Be Inclusive
- Use clear, accessible language
- Avoid unnecessary jargon
- Consider global perspectives
- Support non-native English speakers

### Be Patient
- Learning takes time
- Everyone starts somewhere
- Mistakes are learning opportunities
- Progress over perfection

## 🎓 Learning Together

### Share Your Journey
- Blog about your experience
- Create video tutorials
- Share cost-saving tips
- Document your mistakes and solutions

### Ask Questions
- No question is too basic
- Questions help improve documentation
- Your confusion helps others
- Intellectual humility is valued

### Teach Others
- Answer questions in issues
- Write tutorials
- Create examples
- Share your episodes

## 📞 Getting Help

### Resources
- **Documentation**: `.claude/context/` (Markdown format)
- **Quick Start**: `README.md`
- **Troubleshooting**: `.claude/context/operations/01_troubleshooting_guide.md`
- **Learning Path**: `.claude/context/foundation/02_walk_crawl_run_phases.md`

### Contact
- **GitHub Issues**: Technical problems and bugs
- **GitHub Discussions**: Ideas and questions
- **Repository**: [GitHub](https://github.com/swm-sink/ai-podcasts-nobody-knows)

## 🙏 Recognition

Contributors are recognized in:
- `CONTRIBUTORS.md` file
- Release notes
- Project documentation
- Community highlights

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Remember**: This project is about learning together. Every contribution, question, and idea makes the community stronger. Nobody knows everything, and that's exactly the point! 🎉
