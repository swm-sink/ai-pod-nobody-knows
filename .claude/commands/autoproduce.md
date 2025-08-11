Automatically produce a podcast episode: $ARGUMENTS

USAGE: /autoproduce [project_name] [topic] [optional:episode_number]

PRODUCTION PIPELINE:
1. Load project configuration and brand voice
2. Research topic using Perplexity API
3. Generate script with brand voice consistency
4. Synthesize audio using ElevenLabs v3
5. Evaluate quality metrics
6. Export episode if quality gates pass

QUALITY GATES:
- Comprehension score ≥ 0.85
- Brand consistency ≥ 0.90
- Duration within ±2 minutes of target
- Cost within budget limit

EXAMPLE:
/autoproduce nobody-knows "The Science of Sleep" 15

OUTPUT:
- Episode script at projects/[project]/episodes/ep[number]_script.md
- Audio file at projects/[project]/episodes/ep[number]_audio.mp3
- Quality report at projects/[project]/episodes/ep[number]_quality.json
- Cost tracking updated