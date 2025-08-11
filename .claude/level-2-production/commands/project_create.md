Create new AI content production project: $ARGUMENTS

USAGE: /project:create [project_name] [project_type] [episode_duration]

PROJECT TYPES:
- long_series: 50+ episode educational series (default: 27-min)
- short_series: 10-20 episode focused series (15-min)
- interview_series: Guest-based format with consistent structure
- news_series: Regular update content (5-10 min)
- custom: Flexible configuration for unique requirements

SETUP PROCESS:
1. Create project directory structure in projects/[project_name]/
2. Initialize project configuration file
3. Create brand_voice.md template
4. Set up episode_structure.md template
5. Configure quality_gates.json
6. Initialize project-specific memory store
7. Set cost budget and monitoring

EXAMPLE:
/project:create tech-explained long_series 25

OUTPUT: 
- Project directory created at projects/[project_name]/
- Configuration files initialized
- Ready for episode production